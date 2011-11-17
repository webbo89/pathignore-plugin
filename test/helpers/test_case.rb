module Helpers
  # Custom TestCase that takes care of setup / teardown of Jenkins, git
  # repository, Jenkins::Api and parts of the JobConfigBuilder
  class TestCase < Test::Unit::TestCase
    JENKINS_PORT = 1025 + rand(2**16 - 1024)
    JENKINS_CONTROL_PORT = 1025 + rand(2**16 - 1024)

    def job_name; 'unnamed_job'; end

    def self.startup
      @jenkins = JenkinsManager.new

      @jenkins.copy_plugin(Helpers.hpi_path)

      # TODO: Get ruby-runtime from pluginspec dependencies?
      @jenkins.download_plugin('ruby-runtime', '0.6')
      @jenkins.download_plugin('git', '1.1.12')

      @jenkins.start
    end

    def self.shutdown
      @jenkins.stop

      sleep(1)
      FileUtils.rm_r(@jenkins.home)
    end

    def setup
      @repo_path = Dir.mktmpdir("git-")
      @repo = Grit::Repo.init(@repo_path)
      create_git_files('Initial commit', '.empty')
    end

    def teardown
      Jenkins::Api.delete_job(job_name)
      FileUtils.rm_r(@repo_path)
    end
  end
end
