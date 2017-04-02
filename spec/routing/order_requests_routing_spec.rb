require "rails_helper"

RSpec.describe OrderRequestsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/order_requests").to route_to("order_requests#index")
    end

    it "routes to #new" do
      expect(:get => "/order_requests/new").to route_to("order_requests#new")
    end

    it "routes to #show" do
      expect(:get => "/order_requests/1").to route_to("order_requests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/order_requests/1/edit").to route_to("order_requests#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/order_requests").to route_to("order_requests#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/order_requests/1").to route_to("order_requests#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/order_requests/1").to route_to("order_requests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/order_requests/1").to route_to("order_requests#destroy", :id => "1")
    end

  end
end
