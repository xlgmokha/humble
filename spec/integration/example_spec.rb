require "spec_helper"
require_relative 'fixtures/movie_mapping.rb'

describe "orm" do
  let(:connection) { Sequel.connect(connection_string) }
  let(:connection_string) { 'sqlite://test.db' }
  let(:configuration) { Humble::Configuration.new(connection_string) }
  let(:session_factory) { configuration.build_session_factory }
  let(:session) { session_factory.create_session }

  before :each do
    connection.create_table :movies do
      primary_key :id
      String :name
    end

    configuration.add(MovieMapping.new)
  end

  after :each do
    connection.drop_table :movies
  end

  context "when fetching all items" do
    before :each do
      connection[:movies].insert(:name => 'monsters inc')
    end

    let(:results) { session.find_all Movie }

    it "should return the correct number of movies" do
      results.count.should == 1
    end

    it "should return each movie with its name" do
      results.first.name.should == 'monsters inc'
    end

    it "should return instances of the target type" do
      results.first.should be_instance_of(Movie)
    end
  end

  context "when inserting a new record" do
    before :each do
      session.begin_transaction do |session|
        session.save(Movie.new(:name => 'oop'))
      end
    end

    let(:results) { connection[:movies].all }

    it "should insert the correct number of records" do
      results.count.should == 1
    end

    it "should insert the record with the a new id" do
      results.first[:id].should_not == -1
      results.first[:id].should > 0
    end

    it "should insert the name" do
      results.first[:name].should == 'oop'
    end
  end

end
