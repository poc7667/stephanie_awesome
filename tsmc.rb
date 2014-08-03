# encoding: utf-8
Encoding.default_external = "UTF-8"
require 'pry'
require 'pry-nav'
require 'pry-byebug'
require 'erb'
require 'erubis'
require 'awesome_print'
require 'pathname'

class Tsmc
   def initialize(im_file)
       @im_file = im_file
       @mps = {}
       @current_mp = nil
   end

   def read_file
     File.open(@im_file).each do |line|
      line = line.gsub(/\t/," ").gsub(/\s+/," ")
      m=line.scan(/(.*)(MP\s+)(\d+)(.*)/) #if match "$result 1 MP 65 -2,3 12405025,5599359 72232787,235591230 62,-1 0 0 1 1 nm 2912."
      if m.count > 0 # means matching above condition
        @current_mp = m[0][2].strip.to_i
        data = m[0].last.strip.split(" ")
        @xy = data[0]
        @mps[@current_mp] ||= {}
        @mps[@current_mp][@xy] = {
          remain: data[1..-1]
        }
      else 
        m = line.scan(/(\d:\s)(\w+\'{0,1})(\s+)(\:)(.*)/)
        if m.count > 0         
          @mps[@current_mp][@xy][m[0][1]] = m[0].last.rstrip
        end
      end
     end #end of File open
   end
   
   def show_result
     ap(@mps)
     @mps.each do |mp_number, mp_value|
       p mp_number
       mp_value.each do |key ,values|
         p key,values["Mean"]
       end
     end    
   end
end

tsmc = Tsmc.new(ARGV[0])
tsmc.read_file
tsmc.show_result