require "rails_helper"

RSpec.describe MasterSetup::InterestRatesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/master_setup/interest_rates").to route_to("master_setup/interest_rates#index")
    end

    it "routes to #new" do
      expect(:get => "/master_setup/interest_rates/new").to route_to("master_setup/interest_rates#new")
    end

    it "routes to #show" do
      expect(:get => "/master_setup/interest_rates/1").to route_to("master_setup/interest_rates#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/master_setup/interest_rates/1/edit").to route_to("master_setup/interest_rates#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/master_setup/interest_rates").to route_to("master_setup/interest_rates#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/master_setup/interest_rates/1").to route_to("master_setup/interest_rates#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/master_setup/interest_rates/1").to route_to("master_setup/interest_rates#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/master_setup/interest_rates/1").to route_to("master_setup/interest_rates#destroy", :id => "1")
    end

  end
end
