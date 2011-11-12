require 'test_helper'

class IgnoreTest < Helpers::TestCase
  include Helpers

  def job_name; "ignore_test_job"; end

  def setup
    super
    create_job(job_name, config_builder(['**/ignored']))
  end

  def test_single_file_match_not_built
    create_git_files(@method_name, 'bar/ignored')
    build = build_job_and_wait

    assert_build_not_built(build)
  end

  def test_multiple_files_all_match_not_built
    create_git_files(@method_name, 'bar/ignored', 'foo/ignored')
    build = build_job_and_wait

    assert_build_not_built(build)
  end

  def test_single_file_no_match_built
    create_git_files(@method_name, 'bar/bar')
    build = build_job_and_wait

    assert_build_success(build)
  end

  def test_multiple_files_no_match_built
    create_git_files(@method_name, 'bar/bar', 'foo/bar')
    build = build_job_and_wait

    assert_build_success(build)
  end

  def test_multiple_files_some_match_built
    create_git_files(@method_name, 'bar/bar', 'foo/ignored')
    build = build_job_and_wait

    assert_build_success(build)
  end
end
