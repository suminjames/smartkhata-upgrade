require "rails_helper"

RSpec.describe EsewaPaymentsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/esewa_payments").to route_to("esewa_payments#index")
    end

    it "routes to #new" do
      expect(:get => "/esewa_payments/new").to route_to("esewa_payments#new")
    end

    it "routes to #show" do
      expect(:get => "/esewa_payments/1").to route_to("esewa_payments#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/esewa_payments/1/edit").to route_to("esewa_payments#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/esewa_payments").to route_to("esewa_payments#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/esewa_payments/1").to route_to("esewa_payments#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/esewa_payments/1").to route_to("esewa_payments#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/esewa_payments/1").to route_to("esewa_payments#destroy", :id => "1")
    end

  end
end
