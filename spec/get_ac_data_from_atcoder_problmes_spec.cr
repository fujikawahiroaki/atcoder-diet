require "./spec_helper"

describe "GetAcDataFromAtCoderProblems" do
  it "get tomorrow allowed calorie" do
    tomorrow_allowed_calorie = GetAcDataFromAtCoderProblems.calc_tomorrow_allowed_calorie("fujikawahiroaki")
    tomorrow_allowed_calorie.should be_a(Int64)
  end

  it "get today allowed calorie" do
    today_allowed_calorie = GetAcDataFromAtCoderProblems.calc_today_allowed_calorie("fujikawahiroaki")
    today_allowed_calorie.should be_a(Int64)
  end
end
