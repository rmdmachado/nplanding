helpers do
  def link_to_javascript(filename)
    "<script type=\"text/javascript\" src=#{filename} charset=\"utf-8\"></script>"
  end

  def add_to_newsletter(filename, email)
    File.open(filename, 'a') do |f|
      f.puts email
    end
  end

  def email_exists?(filename, email)
    File.readlines(filename).grep(/#{email}/).any?
  end
end
