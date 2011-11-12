require 'net/https'

module Helpers
  class JenkinsManager
    DOWNLOAD_CENTER_URL = 'https://updates.jenkins-ci.org/download/plugins/%s/%s/%s.hpi'
    JENKINS_PORT = 1025 + rand(2**16 - 1024)
    JENKINS_CONTROL_PORT = 1025 + rand(2**16 - 1024)
    PLUGIN_CACHE = File.join(Helpers.root_path, '.plugin_cache')

    RedirectLimitError = Class.new(RuntimeError)

    attr_reader :home

    def initialize(home=nil)
      @home = home || Dir.mktmpdir("jenkins-")
      @plugins_path = File.join(@home, 'plugins')
      FileUtils.mkdir_p(@plugins_path)
    end

    def plugin_path(plugin, version)
      File.join(PLUGIN_CACHE, plugin, version, "#{plugin}.hpi")
    end

    def copy_plugin(plugin)
      FileUtils.cp(plugin, @plugins_path)
    end

    def download_plugin(plugin, version)
      path = plugin_path(plugin, version)
      if not File.exist?(path)
        FileUtils.mkdir_p(File.dirname(path))
        output = open(path, 'wb')
        begin
          download_file(DOWNLOAD_CENTER_URL % [plugin, version, plugin], output)
        rescue
          File.unlink(path)
          raise
        ensure
          output.close
        end
      end
      copy_plugin(path)
    end

    def download_file(url_str, output, tries=5)
      raise RedirectLimitError, "Too many redirects trying to download file" if tries < 1

      url = URI.parse(url_str)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url_str.start_with?('https')
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      http.request_get(url.path) do |resp|
        if resp.kind_of?(Net::HTTPRedirection)
          download_file(resp['location'], output, tries - 1)
        else
          resp.value
          resp.read_body do |segment|
            output.write(segment)
          end
        end
      end
    end
    private :download_file

    def start
      puts "Starting Jenkins"
      puts " $ jenkins server --home='#{@home}' --port=#{JENKINS_PORT} --control=#{JENKINS_CONTROL_PORT}"
      @jenkins = IO.popen("jenkins server --home='#{@home}' --port=#{JENKINS_PORT} --control=#{JENKINS_CONTROL_PORT} 2>&1")
      line = @jenkins.readline while line.nil? or line !~ /Jenkins is fully up and running/
      puts "Jenkins started!"

      Jenkins::Api.setup_base_url(:host => 'localhost', :port => JENKINS_PORT)
    end

    def stop
      if not @jenkins.nil?
        %x[jenkins server --control=#{JENKINS_CONTROL_PORT} --kill]
        @jenkins.close
      end
    end
  end
end
