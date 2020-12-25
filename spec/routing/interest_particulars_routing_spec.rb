require "rails_helper"

RSpec.describe InterestParticularsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/interest_particulars").to route_to("interest_particulars#index")
    end

    it "routes to #new" do
      expect(:get => "/interest_particulars/new").to route_to("interest_particulars#new")
    end

    it "routes to #show" do
      expect(:get => "/interest_particulars/1").to route_to("interest_particulars#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/interest_particulars/1/edit").to route_to("interest_particulars#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/interest_particulars").to route_to("interest_particulars#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/interest_particulars/1").to route_to("interest_particulars#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/interest_particulars/1").to route_to("interest_particulars#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/interest_particulars/1").to route_to("interest_particulars#destroy", :id => "1")
    end

  end
end
