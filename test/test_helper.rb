require 'rubygems'
require 'bundler/setup'

require 'tmpdir'
require 'fileutils'

require 'test/unit'
require 'grit'

module Helpers
  def self.root_path
    File.expand_path(File.dirname(__FILE__) + '/..')
  end

  def self.hpi_path
    File.join(root_path, 'pkg', 'pathignore.hpi')
  end

  def assert_build_success(build)
    assert_equal(build['result'], 'SUCCESS')
  end

  def assert_build_not_built(build)
    assert_equal(build['result'], 'NOT_BUILT')
  end

  def create_git_files(message, *files)
    Dir.chdir(@repo_path) do
      files.each do |file|
        FileUtils.mkdir_p(File.dirname(file)) if file.include? '/'
        FileUtils.touch(file)
        @repo.add(file)
      end
    end

    @repo.commit_index(message)
  end

  def create_job(job, config)
    Jenkins::Api.create_job(job, config)
    build_job_and_wait(job)
  end

  def build_job_and_wait(job=nil)
      job ||= job_name

      # TODO: Use job_info['nextBuildNumber'] and
      # job_info['builds'].first['number'] or
      # job_info['lastCompletedBuild']['number']?
      job_info = Jenkins::Api.job(job)
      original_num_builds = job_info['builds'].length

      return nil if not Jenkins::Api.build_job(job)

      begin
        job_info = Jenkins::Api.job(job)
      end while not job_info['queueItem'].nil? or job_info['builds'].length <= original_num_builds

      number = job_info['builds'].first['number']
      begin
        build = Jenkins::Api.build_details(job, number)
      end while build['building']

      build
  end
end

require 'helpers/jenkins_ext'
require 'helpers/job_config_builder'
require 'helpers/jenkins_manager'
require 'helpers/test_case'
