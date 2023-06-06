require "kemal"
require "dotenv"
require "./get_ac_data_from_atcoder_problems"

module AtCoderDiet
  VERSION = "0.1.0"

  class Server
    def initialize
    end

    def set_route
      get "/" do |env|
        render "public/index.html.ecr", "public/layout.html.ecr"
      end
      post "/" do |env|
        Time.local Time::Location.load("Asia/Tokyo")
        atcoder_id = env.params.body["atcoder_id"].as(String)
        today_allowed_calorie = 2000i64 + GetAcDataFromAtCoderProblems.calc_today_allowed_calorie(atcoder_id) 
        tomorrow_allowed_calorie = 2000i64 + GetAcDataFromAtCoderProblems.calc_tomorrow_allowed_calorie(atcoder_id)
        render "public/result.html.ecr", "public/layout.html.ecr"
      end
      get "/*" do |env|
        env.response.status_code = 404
        render "public/not_found.html.ecr"
      end
    end

    def serve
      self.set_route
      Kemal.run port: 8080
    end
  end
end

Dotenv.load
server = AtCoderDiet::Server.new
server.serve
