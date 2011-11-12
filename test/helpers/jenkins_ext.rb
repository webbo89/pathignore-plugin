require 'jenkins'

module Jenkins
  module Api
    def self.build_job(name)
      # This is like the original one, except ?delay=0sec isn't included.
      res = get_plain "/job/#{name}/build?delay=0sec"
      res.code.to_i == 302
    end
  end
end
