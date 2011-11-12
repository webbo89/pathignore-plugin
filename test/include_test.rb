require 'test_helper'

class IncludeTest < Helpers::TestCase
  include Helpers

  def job_name; "include_test_job"; end

  def setup
    super
    create_job(job_name, config_builder(['**/included'], true))
  end

  def test_single_file_match_built
    create_git_files(@method_name, 'bar/included')
    build = build_job_and_wait

    assert_build_success(build)
  end

  def test_multiple_files_some_match_built
    create_git_files(@method_name, 'bar/included', 'foo/bar')
    build = build_job_and_wait

    assert_build_success(build)
  end

  def test_multiple_files_all_match_built
    create_git_files(@method_name, 'bar/included', 'foo/included')
    build = build_job_and_wait

    assert_build_success(build)
  end

  def test_single_file_no_match_not_built
    create_git_files(@method_name, 'bar/bar')
    build = build_job_and_wait

    assert_build_not_built(build)
  end

  def test_multiple_files_no_match_not_built
    create_git_files(@method_name, 'bar/bar', 'foo/bar')
    build = build_job_and_wait

    assert_build_not_built(build)
  end
end
