def opsworks_cookbook(name, branch = nil)
  cookbook name, github: 'ace-cookbooks/opsworks-cookbooks', branch: 'patches', rel: name
end

def forked_cookbook(name, branch = nil)
  branch ||= name
  cookbook name, github: 'ace-cookbooks/opsworks-cookbooks', branch: branch, rel: name
end

%w{ rails deploy nginx apache2 scm_helper dependencies mod_php5_apache2 packages gem_support ruby_enterprise build-essential mysql
  ruby opsworks_rubygems opsworks_bundler opsworks_nodejs opsworks_commons }.each do |cb|
  opsworks_cookbook cb
end

forked_cookbook 'unicorn'
forked_cookbook 'haproxy'

cookbook 'opsworks_remote_logging', github: 'ace-cookbooks/opsworks_remote_logging', branch: 'master'
cookbook 'ops_preflight', github: 'ace-cookbooks/ops_preflight', branch: 'master'
