require "http/client"
require "kemal"
require "json"

module GetAcDataFromAtCoderProblems
  extend self

  # AtCoder ProblemsのAPIから提出データを取得し、解いた問題のidとスコアと日付のNamedTupleを返す
  # 提出データの取得エラーが起きた場合はnilを返す
  # いつからの提出データを取得するかはunix秒(Int64)の引数で指定
  def get_ac_data(user_id : String, start_time : Int64) : Array(NamedTuple(problem_id: String, point: Int64, year: Int64, month: Int64, day: Int64)) | Nil
    Time.local Time::Location.load("Asia/Tokyo")
    # AtCoder Problemsからその日の提出データを取得
    submissions_url = "https://kenkoooo.com/atcoder/atcoder-api/v3/user/submissions?user=#{user_id}&from_second=#{start_time}"
    submissions_res = HTTP::Client.get(submissions_url)
    if submissions_res.status_code == 200
      ac_data = [] of NamedTuple(problem_id: String, point: Int64, year: Int64, month: Int64, day: Int64)
      submissions = JSON.parse(submissions_res.body).as_a
      submissions.sort_by! { |s| -(s["point"].as_f.to_i64)}
      done = Set({String, Int64, Int64, Int64}).new
      submissions.each do |submission|
        next if submission["result"].as_s != "AC"
        problem_id = submission["problem_id"].as_s
        point = submission["point"].as_f.to_i64
        point = 300i64 if problem_id.includes?("ahc")
        date = Time.unix(submission["epoch_second"].as_i64).to_local
        year = date.year.to_i64
        month = date.month.to_i64
        day = date.day.to_i64
        submission_data_for_done_check = {problem_id, year, month, day}
        next if done.includes?(submission_data_for_done_check)
        done << {problem_id, year, month, day}
        ac_data << {problem_id: problem_id, point: point, year: year, month: month, day: day}
      end
      ac_data
    else
      nil
    end
  end

  # 当日に解いた問題のスコアから翌日の摂取可能カロリーを返す
  def calc_tomorrow_allowed_calorie(user_id : String) : Int64
    Time.local Time::Location.load("Asia/Tokyo")
    Log.info { "calc_tomorrow today_start: #{Time.local.at_beginning_of_day}"}
    ac_data = get_ac_data(user_id, Time.local.at_beginning_of_day.to_unix)
    if ac_data
      return ac_data.sum { |a| a["point"] }
    else
      return 0i64
    end
  end

  # 前日に解いた問題のスコアから当日の摂取可能カロリーを返す
  def calc_today_allowed_calorie(user_id : String) : Int64
    Time.local Time::Location.load("Asia/Tokyo")
    Log.info { "calc_today today_start: #{Time.local.at_beginning_of_day}"}
    beginning_today = Time.local.at_beginning_of_day.to_unix
    beginning_yesterday = beginning_today - (60i64 * 60 * 24)
    today_day = Time.local.day
    ac_data = get_ac_data(user_id, beginning_yesterday)
    if ac_data
      return ac_data.map { |a| a["day"] != today_day ? a["point"] : 0i64 }.sum
    else
      return 0i64
    end
  end
end
