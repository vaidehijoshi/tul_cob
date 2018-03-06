# frozen_string_literal: true

module CatalogHelper
  include Blacklight::CatalogHelperBehavior
  include BlacklightAlma::CatalogOverride

  def render_availability(document = @document)
		render :partial => 'show_availability', :locals => {:document => document}
  end

	def openurl(mms_id, service='viewit')
		url = openurl_base + "rfr_id=info:sid/primo.exlibrisgroup.com&u.ignore_date_coverage=true&svc_dat=#{service}&rft.mms_id=#{mms_id}"
		url += "&sso=true&token=#{session.id}" if current_user && current_user.provider=='saml'
		url += "&oauth=true&provider=#{current_user.provider.downcase}" if current_user && ["FACEBOOK", "GOOGLE"].include?(current_user.provider)
		url
	end

  def thumbnail_classes(document)
    classes = %w[thumbnail col-sm-3 col-lg-2]
    document[:format].each do |format|
      classes << "#{format.parameterize.downcase.underscore}_format"
    end
    classes.join " "
  end

  def isbn_data_attribute(document)
    value = document.fetch(:isbn_display, "")
    return value if value.empty?
    # Get the first ISBN and strip non-numerics
    "data-isbn=#{value.first.gsub(/\D/, '')}"
  end

  def lccn_data_attribute(document)
    value = document.fetch(:lccn_display, "")
    return value if value.empty?
    # Get the first ISSN and strip non-numerics
    "data-lccn=#{value.first.gsub(/\D/, '')}"
  end


  def default_cover_image(document)
    "svg/" + document.fetch(:format, "unknown")[0].to_s.parameterize.underscore + ".svg"
  end

  def separate_formats(document)
    formats = %w[]
    document[:format].each do |format|
      formats << '<span class="' + "#{format.to_s.parameterize.underscore}" + '">' + format.to_s + "</span>".html_safe
    end
    formats.join('<span class="format-concatenator">and</span>')
  end
end
