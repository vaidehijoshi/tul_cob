require "library_stdnums"

# A set of custom traject macros (extractors and normalizers) used by the
module Traject
  module Macros
    module Custom
      NOT_FULL_TEXT = /book review|publisher description|sample text|table of contents/i

      def get_xml
        lambda do |rec, acc|
          acc << MARC::FastXMLWriter.encode(rec)
        end
      end

      def to_single_string
        Proc.new do |rec, acc|
          acc.replace [acc.join(" ")] # turn it into a single string
        end
      end

      def first_letters_only
        Proc.new do |rec, acc|
          # Just get the first letter to send to the translation map
          acc.map! { |x| x[0] }
        end
      end

      def extract_electronic_resource
        lambda do |rec, acc|
          rec.fields("PRT").each do |f|
            selected_subfields = [f["a"], f["c"], f["g"]].compact.join("|")
            acc << selected_subfields
          end
          rec.fields("856").each do |f|
            case f.indicator2
            when "0"
              z3 = [f["z"], f["3"]].join(" ")
              unless NOT_FULL_TEXT.match(z3)
                if z3 == " "
                  z3 = f["y"] || "Link to Resource"
                  z3 << "|#{f["u"]}" unless f["u"].nil?
                  acc << z3
                else
                  z3 << "|#{f["u"]}" unless f["u"].nil?
                  acc << z3
                end
              end
            when "2"
              # do nothing
            else
              z3 = [f["z"], f["3"]].join(" ")
              unless NOT_FULL_TEXT.match(z3)
                if z3 == " "
                  z3 = f["y"] || "Link to Resource"
                  z3 << "|#{f["u"]}" unless f["u"].nil?
                  acc << z3
                else
                  z3 << "|#{f["u"]}" unless f["u"].nil?
                  acc << z3
                end
              end
            end
          end
        end
      end

      def extract_url_more_links
        lambda { |rec, acc|
          rec.fields("856").each do |f|
            case f.indicator2
            when "2"
              z3 = [f["z"], f["3"]].join(" ")
              if z3 == " "
                z3 = f["y"] || "Link to Resource"
                z3 << "|#{f["u"]}" unless f["u"].nil?
                acc << z3
              else
                z3 << "|#{f["u"]}" unless f["u"].nil?
                acc << z3
              end
            when "0"
              # do nothing
            else
              z3 = [f["z"], f["3"]].join(" ")
              if NOT_FULL_TEXT.match(z3)
                if z3 == " "
                  z3 = f["y"] || "Link to Resource"
                  z3 << "|#{f["u"]}" unless f["u"].nil?
                  acc << z3
                else
                  z3 << " |#{f["u"]}" unless f["u"].nil?
                  acc << z3
                end
              end
            end
          end
        }
      end

      def extract_availability
        lambda { |rec, acc|
          unless rec.fields("PRT").empty?
            acc << "Online"
          end
          unless acc.include?("Online")
            rec.fields(["856"]).each do |field|
              z3 = [field["z"], field["3"]].join(" ")
              unless NOT_FULL_TEXT.match(z3) || rec.fields("856").empty?
                acc << "Online" if field.indicator1 == "4" && field.indicator2 != "2"
              end
            end
          end
          unless rec.fields("HLD").empty?
            acc << "At the Library"
          end
          acc.uniq!
        }
      end

      def extract_location
        lambda { |rec, acc|
          rec.fields("945").each do |field|
            #Strip the values, as many come in with space padding
            acc << field["l"].strip unless field["l"].nil?
          end
        }
      end

      def normalize_lc_alpha
        Proc.new do |rec, acc|
          alpha_pat = /\A([A-Z]{1,3})\d.*\Z/
          acc.map! do |x|
            (m = alpha_pat.match(x)) ? m[1] : nil
          end
          acc.compact! # eliminate nils
        end
      end

      def normalize_format
        Proc.new do |rec, acc|
          acc.delete("Print")
          acc.delete("Online")
          # replace Archival with Archival Material
          acc.map! { |x| x == "Archival" ? "Archival Material" : x }.flatten!
          # replace Conference with Conference Proceedings
          acc.map! { |x| x == "Conference" ? "Conference Proceedings" : x }.flatten!
        end
      end

      def normalize_isbn
        Proc.new do |rec, acc|
          orig = acc.dup
          acc.map! { |x| StdNum::ISBN.allNormalizedValues(x) }
          acc << orig
          acc.flatten!
          acc.uniq!
        end
      end

      def normalize_issn
        Proc.new do |rec, acc|
          orig = acc.dup
          acc.map! { |x| StdNum::ISSN.normalize(x) }
          acc << orig
          acc.flatten!
          acc.uniq!
        end
      end

      def normalize_lccn
        Proc.new do |rec, acc|
          orig = acc.dup
          acc.map! { |x| StdNum::LCCN.normalize(x) }
          acc << orig
          acc.flatten!
          acc.uniq!
        end
      end

      def extract_pub_date
        lambda do |rec, acc|
          rec.fields(["260"]).each do |field|
            acc << four_digit_year(field["c"]) unless field["c"].nil?
          end

          rec.fields(["264"]).each do |field|
            acc << four_digit_year(field["c"]) unless field["c"].nil? || field.indicator2 == "4"
          end
        end
      end

      def extract_copyright
        lambda do |rec, acc|
          rec.fields(["264"]).each do |field|
            acc << four_digit_year(field["c"])  if field.indicator2 == "4"
          end
        end
      end
    end
  end
end