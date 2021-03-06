# frozen_string_literal: true

require "rsolr"

namespace :fortytu do
  namespace :solr do

    desc "Posts fixtures to Solr"
    task :load_fixtures do
      Dir.glob("spec/fixtures/*.xml").sort.reverse.each do |file|
        `traject -c app/models/traject_indexer.rb #{file}`
      end

      `traject -c app/models/traject_indexer.rb -x commit`
    end

    desc "Delete all items from Solr"
    task :clean do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      solr.update data: "<delete><query>*:*</query></delete>"
      solr.update data: "<commit/>"
    end
  end
end

desc "Ingest a single file or all XML files in the sammple_data folder"
task :ingest, [:filepath] => [:environment] do |t, args|
  if args[:filepath]
    `traject -c app/models/traject_indexer.rb #{args[:filepath]}`
  else
    Dir.glob("sample_data/**/*.xml").sort.each do |file|
      `traject -c app/models/traject_indexer.rb #{file}`
    end
  end

  `traject -c app/models/traject_indexer.rb -x commit`
end
