# encoding: UTF-8
require "linode_speedtest/version"

require "awesome_print"
require "benchmark"
require "colored"
require "net/http"
require "nokogiri"
require "filesize"
require "open-uri"
require "progressbar"
require "text-table"
require "uri"

class LinodeSpeedtest
  def initialize
  end

  def download(url)
    Thread.new do
      thread = Thread.current
      body = thread[:body] = []

      url = URI.parse url
      time = Benchmark.realtime do
        Net::HTTP.new(url.host, url.port).request_get(url.path) do |response|
          length = thread[:content_length] = response["Content-Length"].to_i

          response.read_body do |fragment|
            body << fragment
            thread[:done] = (thread[:done] || 0) + fragment.length
            thread[:progress] = [(thread[:done].to_f / length.to_f), 1].min
          end
        end
      end
      thread[:time] = time
    end
  end

  def get_datacenter_page
    Nokogiri::HTML(open("http://www.linode.com/speedtest/"))
  end
  
  def parse_datacenters(document)
    datacenters = document.css("#page_col_left table tr").map do |row|
      array = row.css("td:not(.head)").map do |cell|
        if cell.css("a").any?
          cell.css("a").first["href"]
        else
          cell.text
        end
      end
    end

    datacenters.delete_if do |center|
      center.nil? || center.empty?
    end

    datacenters.map! do |array|
      { name: array[0], host: array[1], url: array[2] }
    end
  end

  def print_datacenter_list(datacenters)
    datacenters.each do |center|
      puts "#{center[:name]} (#{center[:host]}):  \t".white + " #{center[:url]}".cyan
    end
  end

  def run_speedtests(datacenters)
    datacenters.each do |center|
      thread = download(center[:url])
      progress = ProgressBar.new(center[:name], 1)
      progress.set thread[:progress].to_f until thread.join 1
      progress.finish

      center[:content_length] = thread[:content_length]
      center[:done] = thread[:done]
      center[:time] = thread[:time]
      center[:speed] = Filesize.new((thread[:done] / thread[:time]).to_i).pretty + "/s"
    end

    datacenters.sort! {|a,b| a[:time] <=> b[:time] }

    datacenters
  end

  def run
    print "Fetching datacenter list.\t"
    document = get_datacenter_page
    puts "[OK]".green if document

    print "Parsing datacenters.\t\t"
    datacenters = parse_datacenters(document)
    puts "[OK]".green if datacenters.any?

    puts "\nFound these datacenters and test files:"
    print_datacenter_list(datacenters)

    puts "\n== Starting speed tests. This will take quite a long time ==".blue

    datacenters = run_speedtests(datacenters)

    rows = datacenters.map do |center|
      [center[:name], center[:speed]]
    end

    table = Text::Table.new({
      head: ["Datacenter", "Speed"],
      rows: rows,
      horizontal_padding: 2
    })

    puts "\n"
    puts table.to_s
  end
end
