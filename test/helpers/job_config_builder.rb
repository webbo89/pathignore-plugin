module Helpers
  # Custom JobConfigBuilder that allows us to configure a pathignore build
  # wrapper for our new job.
  class JobConfigBuilder < Jenkins::JobConfigBuilder
    attr_accessor :ignored_paths, :invert_ignore
    def initialize(*args)
      self.invert_ignore = false
      super(*args)
    end

    def build_wrappers(b)
      return super(b) if ignored_paths.nil?

      b.buildWrappers do
        b.tag! 'ruby-proxy-object' do
          b.tag! 'ruby-object', :"ruby-class" => "Jenkins::Plugin::Proxies::BuildWrapper", :pluginid => "pathignore" do
            b.pluginid "pathignore", :pluginid => "pathignore", :"ruby-class" => "String"
            b.object :"ruby-class" => "PathignoreWrapper", :pluginid => "pathignore" do
              b.ignored__paths(ignored_paths.join(','), :pluginid => "pathignore", :"ruby-class" => "String")
              b.invert__ignore(invert_ignore.to_s, :pluginid => "pathignore", :"ruby-class" => invert_ignore.class.to_s)
            end
          end
        end
      end
    end
  end

  def config_builder(paths, invert=false)
    JobConfigBuilder.new(:none) do |c|
      c.steps = [[:build_shell_step, "true"]]
      c.scm = "file://#{@repo_path}"
      c.ignored_paths = paths
      c.invert_ignore = invert
    end
  end
end
