def opsworks_cookbook(name, branch = nil)
  cookbook name, github: 'ace-cookbooks/opsworks-cookbooks', branch: 'patches', rel: name
end

def forked_cookbook(name, branch = nil)
  branch ||= name
  cookbook name, github: 'ace-cookbooks/opsworks-cookbooks', branch: branch, rel: name
end

%w{ rails deploy nginx apache2 scm_helper dependencies mod_php5_apache2 packages gem_support ruby_enterprise build-essential mysql }.each do |cb|
  opsworks_cookbook cb
end

forked_cookbook 'ruby'
forked_cookbook 'opsworks_rubygems', 'opsworks-rubygems'
forked_cookbook 'opsworks_bundler', 'opsworks-bundler'
forked_cookbook 'opsworks_nodejs', 'opsworks-nodejs'
forked_cookbook 'opsworks_commons', 'opsworks-commons'

cookbook 'sphinx', github: 'ace-cookbooks/sphinx-cookbook', branch: 'fix-metadata'
