#!/usr/bin/env ruby

@cwd = Dir.pwd

Dir.chdir File.dirname(__FILE__)

require "rubygems"
require "bundler/setup"

require "net/http"
require "json"
require "dotenv/load"
require "tty-prompt"

MAX_LENGTH = ENV["MAX_LENGTH"]&.to_i || 78

def run
  # Switch to calling folder.
  Dir.chdir @cwd

  cards = fetch_cards
  return if cards.empty?

  puts "Available cards:"

  choice = prompt.select("Select card", cards.map.with_index { |card, i| "#{i + 1} - CARD: #{card["number"]} - #{card["title"]}" })
  choice =~ /(\d+) - .*/
  choice = $1.to_i

  selected_card = cards[choice - 1]

  create_branch(selected_card)
end

def query(query)
  url = "https://api.linear.app/graphql"

  headers = {
    "Content-Type" => "application/json",
    "Authorization" => "Bearer #{ENV["LINEAR_API_KEY"]}"
  }

  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(uri.path, headers)
  request.body = { query: query }.to_json

  response = http.request(request)

  JSON.parse(response.body)["data"]
end

def fetch_cards
  state_filters = ENV["STATES"].split(",").map { |state| %Q("#{state}") }.join(", ")

  data = query(<<~GRAPHQL
      {
        issues(filter: {
          assignee: { email: { eq: "#{ENV['ASSIGNEE_EMAIL']}" } }
          state: { type: { in: [#{state_filters}] } }

        }) {
          nodes {
            identifier
            number
            title
          }
        }
    }
    GRAPHQL
  )

  data["issues"]["nodes"]
end

# Create a branch
def create_branch(card)
  branch_type = prompt_branch_type
  branch_name = "#{branch_type}/#{ENV["INITIALS"]}-#{card['identifier'].downcase}-#{card["title"].gsub(/([^a-zA-Z0-9\-]+)/, "-").downcase}"
  branch_name = branch_name[0..MAX_LENGTH]

  # Create the branch.
  `git checkout -b #{branch_name}`
  puts "Created branch: #{branch_name}"
end

def prompt_branch_type
  branch_types = ENV["PREFIX_CHOICES"].split(",")

  puts "Select a branch type:"
  branch_types.each_with_index { |branch, index| puts "#{index + 1}. #{branch}" }

  choice = prompt.select("Select type", branch_types.map.with_index { |branch, i| "#{i + 1} - #{branch}" })
  choice =~ /(\d+) - .*/
  choice = $1.to_i

  branch_types[choice - 1]
end

def prompt
  TTY::Prompt.new
end

run
