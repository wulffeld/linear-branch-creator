#!/usr/bin/env ruby

@cwd = Dir.pwd

Dir.chdir File.dirname(File.realpath(__FILE__))

require "rubygems"
require "bundler/setup"

require "active_support/core_ext/object/blank"
require "active_support/core_ext/enumerable"
require "dotenv"
require "httparty"
require "json"
require "openssl"
require "tty-prompt"

require_relative "lib/format_builder"

# Load config from .linear-branch-creator in the project or .env in this directory.
config_file = File.join(@cwd, ".linear-branch-creator")
fallback_file = File.join(File.dirname(File.realpath(__FILE__)), ".env")

if File.exist?(config_file)
  Dotenv.load(config_file)
elsif File.exist?(fallback_file)
  Dotenv.load(fallback_file)
else
  puts "Error: No config file found. Create .linear-branch-creator in your project or .env in the script directory."
  exit 1
end

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
    "Authorization" => "#{ENV["LINEAR_API_KEY"]}"
  }

  response = HTTParty.post(url, headers: headers, body: { query: query }.to_json)

  JSON.parse(response.body)["data"]
rescue JSON::ParserError => e
  puts "Error parsing response: #{response.body}"
  raise e
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
  branch_name = [
    branch_type,
    [
      card["identifier"],
      ENV["INITIALS"],
      card["title"]
        .gsub(/([\'\`])/, "")
        .gsub(/([^a-zA-Z0-9\-]+)/, "-")
        .downcase
    ].compact_blank.join("-")
  ].compact_blank.join("/")
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
