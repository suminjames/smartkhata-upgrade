require "rails_helper"

RSpec.describe EsewaReceiptsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/esewa_receipts").to route_to("esewa_receipts#index")
    end

    it "routes to #new" do
      expect(:get => "/esewa_receipts/new").to route_to("esewa_receipts#new")
    end

    it "routes to #show" do
      expect(:get => "/esewa_receipts/1").to route_to("esewa_receipts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/esewa_receipts/1/edit").to route_to("esewa_receipts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/esewa_receipts").to route_to("esewa_receipts#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/esewa_receipts/1").to route_to("esewa_receipts#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/esewa_receipts/1").to route_to("esewa_receipts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/esewa_receipts/1").to route_to("esewa_receipts#destroy", :id => "1")
    end

  end
end
