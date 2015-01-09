require 'rest_client'
require 'nokogiri'
require 'json'
require 'iconv'
require 'uri'
require_relative 'course.rb'
# 難得寫註解，總該碎碎念。
class Spider
  attr_reader :semester_list, :courses_list, :query_url, :result_url

  def initialize
  	@query_url = "http://www.jcbooks.com.tw/default.aspx"
    @front_url = "http://www.jcbooks.com.tw/"
    @next_page_url = "&startno="
  end

  def prepare_post_data
    r = RestClient.get @query_url
    ic = Iconv.new("utf-8//translit//IGNORE","big-5")
    @query_page = Nokogiri::HTML(ic.iconv(r.to_s))
    nil
  end

  def get_books
  	# 初始 courses 陣列
    @books = []
    puts "getting books...\n"
    # 一一點進去YO
    @query_page.css('td.link a').each_with_index do |row, index|
      # get every link to every classification
      # puts @front_url + row['href'].to_s

      if (@front_url + row['href'].to_s) == "http://www.jcbooks.com.tw/booklist.aspx?KNDCD=P110"
        next
      end

      r = RestClient.get @front_url + row['href'].to_s
      ic = Iconv.new("utf-8//translit//IGNORE","big-5")
      hello_books = Nokogiri::HTML(ic.iconv(r.to_s))
      
      # print out 有幾頁
      puts "you got " + hello_books.css('span#ctl00_ContentPlaceHolder1_lbTpage').text + " pages here"

      # 做很多次 YO
      hello_books.css('span#ctl00_ContentPlaceHolder1_lbTpage').text.to_i.times do |n| 
        # 從零開始做 注意！
        if n != 0
          r = RestClient.get @front_url + row['href'].to_s + @next_page_url + (n*20).to_s
          puts @front_url + row['href'].to_s + @next_page_url + (n*20).to_s
        else
          r = RestClient.get @front_url + row['href'].to_s
          puts @front_url + row['href'].to_s
        end
        ic = Iconv.new("utf-8//translit//IGNORE","big-5")
        page = Nokogiri::HTML(ic.iconv(r.to_s))

        # 解析網頁，先把書名拿出來
        page.css('td.search2 div.brike a').each_with_index do |row, index|
          book_name = row.text
          author = page.css('td.search2 > a')[index].text
          publish_year = page.css('td.search2:nth-of-type(3)')[index].text
          jcbooks_ISBN = page.css('td.search2:nth-of-type(4)')[index].text
          isbn = page.css('td.search5')[index].text
          price =page.css('td.search6')[index].text

          @books << Course.new({
            :book_name => book_name,
            :author => author,
            :publish_year => publish_year,
            :jcbooks_ISBN => jcbooks_ISBN,
            :isbn => isbn,
            :price => price
            }).to_hash
        end
      end
    end

    
  end
  

  def save_to(filename='courses_p1.json')
    File.open(filename, 'w') {|f| f.write(JSON.pretty_generate(@books))}
  end
    
end






spider = Spider.new
spider.prepare_post_data
spider.get_books
spider.save_to