#!/usr/bin/env ruby
require 'rubygems' # ruby1.9 doesn't "require" it though
require 'thor'
require 'rbconfig'
require 'fileutils'
require 'json'
require 'erb'

def os
  case RbConfig::CONFIG['host_os']
  when /mswin|windows/i
    :windows
  when /linux|arch/i
    :linux
  when /darwin/i
    :darwin
  else
    abort("Unsupported OS #{RbConfig::CONFIG['host_os']}")
  end
end


# using arch to download terraform requires us to get rid of template provider
def arch
  case RbConfig::CONFIG['host_cpu']
  when "x86_64"
    "amd64"
  when 'arm64'
    "arm64"
  when 'amd64'
    "amd64"
  else
    abort("Unsupported CPU arch #{RbConfig::CONFIG['host_cpu']}")
  end
end

# While we are upgrading, downloading both versions
$terraform_current_version = '1.0.11'
$terraform_current_version_url = "https://releases.hashicorp.com/terraform/#{$terraform_current_version}/terraform_#{$terraform_current_version}_#{os}_amd64.zip"


# When changing versions, reinstall terraform
$terraform_new_version = '1.5.7'
$terraform_new_version_url = "https://releases.hashicorp.com/terraform/#{$terraform_new_version}/terraform_#{$terraform_new_version}_#{os}_amd64.zip"
#$terraform_upgraded_stacks = ['cdn-resources', "base-network", "docs", 'adaba', 'bele', 'bonga', "dimtu", "goba", "gode", "jinka", "maji", "mota", "sawla", "worabe", "xiao", "xindi", "yu" ]
$terraform_upgraded_stacks = []

def terraformVersion(dir)
  $terraform_upgraded_stacks.include?(dir.chomp("/"))? "_new" : "" 
end 

def terraformDocVersion(dir)
  $terraform_upgraded_stacks.include?(dir.chomp("/"))? $terraform_new_version : $terraform_current_version 
end


# Directories without terraform stacks
$excluded_dirs = ['cli/', 'conf/', 'modules/']
$pwd = Dir.pwd
$tmp_dir = '.tmp/bin'

class Build < Thor
  desc 'clean_all', 'Clean all folders'
  def clean_all
    puts 'Cleaning .terraform folders'
    Dir['**/.terraform/'].each { |x| FileUtils.rm_rf(x) }
  end

  desc 'clean', 'Clean terraform folder'
  def clean(dir)
    puts "Cleaning terraform files on #{dir}"
    FileUtils.rm_rf("#{dir}/.terraform")
  end

  desc 'install', 'Install required dependencies.'
  def install
    puts "Running on: #{os}"

    puts 'Cleaning temp folder'
    FileUtils.rm_rf($tmp_dir)

    FileUtils.mkdir_p '.tmp/bin'
    puts "\n\n\nAttempting to decrypt secrets using GPG key."
    system('git-crypt unlock') || abort('Error when attempting to decrypt secrets')
    system('chmod 600 conf/provisioning/ssh/terraform-api.key') || abort('Error when setting private key permissions')

    
    system("wget -vvvv -O #{$tmp_dir}/terraform.zip #{$terraform_new_version_url}") || abort('Error when downloading terraform 13')
    system("cd #{$tmp_dir} && unzip terraform.zip && mv terraform terraform_new && rm terraform.zip") || abort('Error when unzipping upgrade terraform')
    

    system("wget -vvvv -O #{$tmp_dir}/terraform.zip #{$terraform_current_version_url}") || abort('Error when downloading terraform 12')
    system("cd #{$tmp_dir} && unzip terraform.zip && mv terraform terraform") || abort('Error when unzipping current terraform')


    FileUtils.cp('conf/openrc-personal-example', 'conf/openrc-personal') unless File.exist?('conf/openrc-personal')
    puts "\n\n\n*** Please edit conf/openrc-personal with your credentials. ***\n\n"
  end

  desc 'init_all', 'Run terraform init in all subfolders'
  def init_all
    (Dir['*/'] - $excluded_dirs).sort.each do |d|
      suffix=terraformVersion(d)
      puts "Running terraform init on #{d}"
      system("source conf/openrc && cd #{d} && #{$pwd}/#{$tmp_dir}/terraform#{suffix} init -upgrade=true -force-copy") || abort
    end
  end

  desc 'init DIR', 'Run terraform init on DIR'
  def init(dir)
    suffix=terraformVersion(dir)
    puts "Running terraform#{suffix} init on #{dir}"
    system("source conf/openrc && cd #{dir} && #{$pwd}/#{$tmp_dir}/terraform#{suffix} init -upgrade=true -force-copy") || abort
  end

  desc 'validate DIR', 'Run terraform validate on DIR'
  def validate(dir)
    suffix=terraformVersion(dir) 
    puts "Running terraform validate on #{dir}"
    system("source conf/openrc && cd #{dir} && #{$pwd}/#{$tmp_dir}/terraform#{suffix} validate") || abort
  end

  desc 'plan DIR', 'run terraform plan on defined directory'
  def plan(dir)
    suffix=terraformVersion(dir) 
    puts "Running terraform#{suffix} plan on #{dir}"
    system("source conf/openrc && cd #{dir} && #{$pwd}/#{$tmp_dir}/terraform#{suffix} plan -out terraform.plan") || abort
  end

  desc 'plan_all', 'Run terraform plan in all subfolders'
  def plan_all
    (Dir['*/'] - $excluded_dirs).sort.each do |d|
      suffix=terraformVersion(d)
      puts "Running terraform plan on #{d}"
      system("source conf/openrc && cd #{d} && #{$pwd}/#{$tmp_dir}/terraform#{suffix} plan -compact-warnings") || abort
    end
  end

  desc 'apply DIR', 'run terraform apply on defined directory'
  def apply(dir)
    suffix=terraformVersion(dir) 
    puts "Terraform apply is NOT thread-safe, and there's no lock mechanism enabled. Two concurrent calls on the same stack will cause inconsistences."
    printf "Do you really want to modify stack #{dir}? [y/N]:  "
    prompt = STDIN.gets.chomp
    return unless prompt == 'y'

    puts "Running terraform apply on #{dir}"
    system("source conf/openrc && cd #{dir} && #{$pwd}/#{$tmp_dir}/terraform#{suffix} apply terraform.plan") || abort
  end

  desc 'destroy DIR', 'completely deletes VM and data'
  def destroy(dir)
    suffix=terraformVersion(dir) 
    puts "Make sure to change prevent_destroy to true following README file."
    printf "Do you really want to delete stack #{dir}? [y/N]:  "
    prompt = STDIN.gets.chomp
    return unless prompt == 'y'

    puts "Running terraform destroy on #{dir}"
    system("source conf/openrc && cd #{dir} && #{$pwd}/#{$tmp_dir}/terraform#{suffix} destroy") || abort
  end

  desc 'taint-vm DIR', 'mark virtual machine for re creation in DIR'
  def taint_vm(dir)
    suffix=terraformVersion(dir) 
    puts "Running terraform taint on #{dir} (vm resources)"
    system(''"source conf/openrc && cd #{dir} \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.openstack_compute_instance_v2.vm \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.openstack_compute_volume_attach_v2.attach_data_volume[0] || true \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.null_resource.mount_data_volume[0] || true \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.null_resource.upgrade[0] \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.null_resource.copy_facts[0] \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.null_resource.ansible[0] || true \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.null_resource.copy_facts_backups[0] || true \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.template_file.provisioning_file_backup[0] || true \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.null_resource.add_github_key[0] || true \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.null_resource.add_gitcrypt_key[0] || true \
    "'') || abort
  end

  desc 'taint-data DIR', 'mark data storage for re creation in DIR'
  def taint_data(dir)
    suffix=terraformVersion(dir) 
    puts "Running terraform taint on #{dir} (data resources)"
    system(''"source conf/openrc && cd #{dir} \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.openstack_blockstorage_volume_v3.data_volume[0] \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.openstack_compute_volume_attach_v2.attach_data_volume[0] || true \
      && #{$pwd}/#{$tmp_dir}/terraform#{suffix} taint -allow-missing module.single-machine.null_resource.mount_data_volume[0] || true
    "'') || abort
  end

  desc "terraform DIR 'subcommand --args'", 'run arbitrary terraform subcommands on defined directory'
  def terraform(dir, args)
    suffix=terraformVersion(dir) 
    puts "Running terraform \'#{args}\' on #{dir}"
    system("source conf/openrc && cd #{dir} && #{$pwd}/#{$tmp_dir}/terraform#{suffix} #{args}") || abort
  end

  desc 'create DIR', 'creates files for new stack DIR'
  def create(dir)
    suffix="_new"
    puts "Creating stack \'#{dir}\'"
    FileUtils.mkdir_p dir
    FileUtils.cp_r 'conf/template-stack/.', dir
    IO.write("#{dir}/main.tf", File.open("#{dir}/main.tf") do |f|
                                 f.read.gsub(/STACK-NAME/, dir.to_s)
                               end)
    IO.write("#{dir}/variables.tf", File.open("#{dir}/variables.tf") do |f|
                                      f.read.gsub(/STACK-NAME/, dir.to_s)
                                    end)
    FileUtils.ln_sf '../global-variables.tf', "#{dir}/global-variables.tf"
    FileUtils.ln_sf '../versions_terraform_13.tf', "#{dir}/versions.tf"

    system("source conf/openrc && cd #{dir} && #{$pwd}/#{$tmp_dir}/terraform#{suffix} init") || abort
  end

  desc 'docs', 'generate docs in .tmp/docs.md'
  def docs
    $extra_excluded_dirs = $excluded_dirs.push('base-network/', 'docs/', 'cdn-resources/')

    $vms = []

    File.open('.tmp/docs.md', 'w') do |_file|
      (Dir['*/'] - $extra_excluded_dirs).sort.each do |d|
        suffix=terraformVersion(d) 
        version_terraform=terraformDocVersion(d)
        puts "Retrieving outputs for #{d}"
        outputs = `source conf/openrc && cd #{d} && #{$pwd}/#{$tmp_dir}/terraform#{suffix} output -json`
        outputs_parsed = JSON.parse(outputs)
        provisioner = outputs_parsed['provisioner']['value']

        next unless provisioner == 'terraform'
        vm_name = d.chomp('/')
        puts "Found terraformed machine #{vm_name}"
        vm = {
          'name'              => vm_name,
          'environment'       => outputs_parsed['ansible_inventory']['value'],
          'size'              => outputs_parsed['flavor']['value'],
          'backup'            => outputs_parsed['has_backup']['value'] == true ? 'Yes' : 'No',
          'data_volume'       => outputs_parsed['has_data_volume']['value'] == true ? "Yes (#{outputs_parsed['data_volume_size']['value']}GB)" : 'No',
          'ip'                => outputs_parsed['ip_address']['value'],
          'dns'               => outputs_parsed['dns_entries']['value'],
          'description'       => outputs_parsed['description']['value'],
          'terraform_version' => version_terraform
        }
        if outputs_parsed['dns_manual_entries']
          vm['manual_dns'] = outputs_parsed['dns_manual_entries']['value']
        end
        $vms.push(vm)
      end
    end

    file_output = 'docs/vms.html'
    erb_str = File.read('conf/docs.erb')
    File.open(file_output, 'w') do |f|
      f.write(ERB.new(erb_str).result)
    end
    puts "File generated in #{file_output}."

    file_output = 'docs/vms.json'
    File.open(file_output, 'w') do |f|
      f.write(JSON.pretty_generate($vms))
    end
    puts "File generated in #{file_output}."

    puts "\n\n\n\n"
    puts 'Update stack <docs> to upload it to S3. '
  end

end

Build.start
