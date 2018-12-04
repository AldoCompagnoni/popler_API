require 'active_record_union'
# ActiveRecord::Base.establish_connection :adapter => :nulldb

def check_limit_offset(params)
  %i(limit offset).each do |p|
    unless params[p].nil?
      begin
        params[p] = Integer(params[p])
      rescue ArgumentError
        raise Exception.new("#{p.to_s} is not an integer")
      end
    end
  end
  return params
end

def check_proj_metadata_key(params)
  %i(proj_metadata_key).each do |p|
    unless params[p].nil?
      begin
        params[p] = Integer(params[p])
      rescue ArgumentError
        raise Exception.new("#{p.to_s} is not an integer")
      end
    end
  end
  return params
end

# class Biomass < ActiveRecord::Base
#   self.table_name = 'biomass_table'

#   def self.endpoint(params)
#     params.delete_if { |k, v| v.nil? || v.empty? }
#     params = check_limit_offset(params)
#     raise Exception.new('limit too large (max 1000)') unless (params[:limit] || 0) <= 1000
#     # select
#       # .order('species')
#     limit(params[:limit] || 10)
#       .offset(params[:offset])
#   end
# end

# class Search < ActiveRecord::Base
#   self.table_name = 'count_table'

#   def self.endpoint(params)
#     params.delete_if { |k, v| v.nil? || v.empty? }
#     params = check_limit_offset(params)
#     raise Exception.new('limit too large (max 1000)') unless (params[:limit] || 0) <= 1000

#     # FIXME: for some reason treatment_type_* fields cause problems, not sure why, remnoved for now
#     common_cols = %w(authors authors_contact year day month sppcode genus species datatype spatial_replication_level_1_label spatial_replication_level_1 spatial_replication_level_2_label spatial_replication_level_2 spatial_replication_level_3_label spatial_replication_level_3 spatial_replication_level_4_label spatial_replication_level_4 spatial_replication_level_5_label spatial_replication_level_5 proj_metadata_key structure_type_1 structure_type_2 structure_type_3 structure_type_4 covariates count_observation)
#     # cols1 = %w(treatment_type_1 treatment_type_2 treatment_type_3 covariates count_observation)
    
#     # select(common_cols.join(', ') + ', ' + cols1.join(', '))
#     select(common_cols.join(', '))
#       .joins("JOIN taxa_table ON count_table.taxa_count_fkey = taxa_table.taxa_table_key")
#       .joins("JOIN site_in_project_table ON taxa_table.site_in_project_taxa_key = site_in_project_table.site_in_project_key")
#       .joins("JOIN project_table ON site_in_project_table.project_table_fkey = project_table.proj_metadata_key")
#       .joins("JOIN study_site_table ON site_in_project_table.study_site_table_fkey = study_site_table.study_site_key")
#       .joins("JOIN lter_table ON study_site_table.lter_table_fkey = lter_table.lterid")
#       .where(sprintf("proj_metadata_key = %s", params[:proj_metadata_key]))
#       .limit(params[:limit] || 10)
#       .offset(params[:offset])
#   end
# end

class Summary < ActiveRecord::Base
  self.table_name = 'project_table'

  def self.endpoint(params)
    params.delete_if { |k, v| v.nil? || v.empty? }
    params = check_limit_offset(params)
    raise Exception.new('limit too large (max 1000)') unless (params[:limit] || 0) <= 1000

    common_cols = %w(proj_metadata_key lter_project_fkey title samplingunits datatype structured_type_1 
      structured_type_1_units structured_type_2 structured_type_2_units structured_type_3 
      structured_type_3_units studystartyr studyendyr samplefreq studytype community 
      spatial_replication_level_1_extent spatial_replication_level_1_extent_units 
      spatial_replication_level_1_label spatial_replication_level_1_number_of_unique_reps 
      spatial_replication_level_2_extent spatial_replication_level_2_extent_units 
      spatial_replication_level_2_label spatial_replication_level_2_number_of_unique_reps 
      spatial_replication_level_3_extent spatial_replication_level_3_extent_units 
      spatial_replication_level_3_label spatial_replication_level_3_number_of_unique_reps 
      spatial_replication_level_4_extent spatial_replication_level_4_extent_units 
      spatial_replication_level_4_label spatial_replication_level_4_number_of_unique_reps 
      spatial_replication_level_5_extent spatial_replication_level_5_extent_units 
      spatial_replication_level_5_label spatial_replication_level_5_number_of_unique_reps 
      treatment_type_1 treatment_type_2 treatment_type_3 
      control_group derived authors 
      authors_contact metalink knbid structured_type_4 structured_type_4_units 
      duration_years doi doi_citation structured_data lterid lter_name lat_lter 
      lng_lter currently_funded current_principle_investigator current_contact_email 
      alt_contact_email homepage taxa_table_key site_in_project_taxa_key sppcode 
      kingdom subkingdom infrakingdom superdivision division subdivision superphylum 
      phylum subphylum clss subclass ordr family genus species common_name authority 
      metadata_taxa_key)

    select(common_cols.join(', '))
      .joins("JOIN site_in_project_table ON project_table.proj_metadata_key = site_in_project_table.project_table_fkey")
      .joins("JOIN taxa_table ON site_in_project_table.site_in_project_key = taxa_table.site_in_project_taxa_key")
      .joins("JOIN study_site_table ON site_in_project_table.study_site_table_fkey = study_site_table.study_site_key")
      .joins("JOIN lter_table ON study_site_table.lter_table_fkey = lter_table.lterid")
      .limit(params[:limit] || 100)
      .offset(params[:offset])
  end
end

# /search route models
class Count < ActiveRecord::Base
  self.table_name = 'count_table'
  def self.endpoint(params)
    fields = %w{proj_metadata_key genus species lterid}
    common_cols = %w(authors authors_contact year day month sppcode genus species datatype spatial_replication_level_1_label spatial_replication_level_1 spatial_replication_level_2_label spatial_replication_level_2 spatial_replication_level_3_label spatial_replication_level_3 spatial_replication_level_4_label spatial_replication_level_4 spatial_replication_level_5_label spatial_replication_level_5 proj_metadata_key structure_type_1 structure_type_2 structure_type_3 structure_type_4 count_table.treatment_type_1 count_table.treatment_type_2 count_table.treatment_type_3 covariates count_observation)
    query = select(common_cols.join(', '))
      .joins("JOIN taxa_table  ON count_table.taxa_count_fkey = taxa_table.taxa_table_key")
      .joins("JOIN site_in_project_table ON taxa_table.site_in_project_taxa_key = site_in_project_table.site_in_project_key")
      .joins("JOIN project_table ON site_in_project_table.project_table_fkey = project_table.proj_metadata_key")
      .joins("JOIN study_site_table ON site_in_project_table.study_site_table_fkey = study_site_table.study_site_key")
      .joins("JOIN lter_table ON study_site_table.lter_table_fkey = lter_table.lterid")
      .where("proj_metadata_key = ?", params[:proj_metadata_key])
    query = query.where('genus = ?', params[:genus]) if params[:genus].present?
    query = query.where('species = ?', params[:species]) if params[:species].present?
    query = query.where('lterid = ?', params[:lterid]) if params[:lterid].present?
    query
  end
end

class Biomass < ActiveRecord::Base
  self.table_name = 'biomass_table'
  def self.endpoint(params)
    fields = %w{proj_metadata_key genus species lterid}
    common_cols = %w(authors authors_contact year day month sppcode genus species datatype spatial_replication_level_1_label spatial_replication_level_1 spatial_replication_level_2_label spatial_replication_level_2 spatial_replication_level_3_label spatial_replication_level_3 spatial_replication_level_4_label spatial_replication_level_4 spatial_replication_level_5_label spatial_replication_level_5 proj_metadata_key structure_type_1 structure_type_2 structure_type_3 structure_type_4 biomass_table.treatment_type_1 biomass_table.treatment_type_2 biomass_table.treatment_type_3 covariates biomass_observation)
    query = select(common_cols.join(', '))
      .joins("JOIN taxa_table ON biomass_table.taxa_biomass_fkey = taxa_table.taxa_table_key")
      .joins("JOIN site_in_project_table ON taxa_table.site_in_project_taxa_key = site_in_project_table.site_in_project_key")
      .joins("JOIN project_table ON site_in_project_table.project_table_fkey = project_table.proj_metadata_key")
      .joins("JOIN study_site_table ON site_in_project_table.study_site_table_fkey = study_site_table.study_site_key")
      .joins("JOIN lter_table ON study_site_table.lter_table_fkey = lter_table.lterid")
      .where("proj_metadata_key = ?", params[:proj_metadata_key])
    query = query.where('genus = ?', params[:genus]) if params[:genus].present?
    query = query.where('species = ?', params[:species]) if params[:species].present?
    query = query.where('lterid = ?', params[:lterid]) if params[:lterid].present?
    query
  end
end

class PercentCover < ActiveRecord::Base
  self.table_name = 'percent_cover_table'
  def self.endpoint(params)
    fields = %w{proj_metadata_key genus species lterid}
    common_cols = %w(authors authors_contact year day month sppcode genus species datatype spatial_replication_level_1_label spatial_replication_level_1 spatial_replication_level_2_label spatial_replication_level_2 spatial_replication_level_3_label spatial_replication_level_3 spatial_replication_level_4_label spatial_replication_level_4 spatial_replication_level_5_label spatial_replication_level_5 proj_metadata_key structure_type_1 structure_type_2 structure_type_3 structure_type_4 percent_cover_table.treatment_type_1 percent_cover_table.treatment_type_2 percent_cover_table.treatment_type_3 covariates percent_cover_observation)
    query = select(common_cols.join(', '))
      .joins("JOIN taxa_table ON percent_cover_table.taxa_percent_cover_fkey  = taxa_table.taxa_table_key")
      .joins("JOIN site_in_project_table ON taxa_table.site_in_project_taxa_key = site_in_project_table.site_in_project_key")
      .joins("JOIN project_table ON site_in_project_table.project_table_fkey = project_table.proj_metadata_key")
      .joins("JOIN study_site_table ON site_in_project_table.study_site_table_fkey = study_site_table.study_site_key")
      .joins("JOIN lter_table ON study_site_table.lter_table_fkey = lter_table.lterid")
      .where("proj_metadata_key = ?", params[:proj_metadata_key])
    query = query.where('genus = ?', params[:genus]) if params[:genus].present?
    query = query.where('species = ?', params[:species]) if params[:species].present?
    query = query.where('lterid = ?', params[:lterid]) if params[:lterid].present?
    query
  end
end

class Individual < ActiveRecord::Base
  self.table_name = 'individual_table'
  def self.endpoint(params)
    fields = %w{proj_metadata_key genus species lterid}
    common_cols = %w(authors authors_contact year day month sppcode genus species datatype spatial_replication_level_1_label spatial_replication_level_1 spatial_replication_level_2_label spatial_replication_level_2 spatial_replication_level_3_label spatial_replication_level_3 spatial_replication_level_4_label spatial_replication_level_4 spatial_replication_level_5_label spatial_replication_level_5 proj_metadata_key structure_type_1 structure_type_2 structure_type_3 structure_type_4 individual_table.treatment_type_1 individual_table.treatment_type_2 individual_table.treatment_type_3 covariates individual_observation)
    query = select(common_cols.join(', '))
      .joins("JOIN taxa_table ON individual_table.taxa_individual_fkey = taxa_table.taxa_table_key")
      .joins("JOIN site_in_project_table ON taxa_table.site_in_project_taxa_key = site_in_project_table.site_in_project_key")
      .joins("JOIN project_table ON site_in_project_table.project_table_fkey = project_table.proj_metadata_key")
      .joins("JOIN study_site_table ON site_in_project_table.study_site_table_fkey = study_site_table.study_site_key")
      .joins("JOIN lter_table ON study_site_table.lter_table_fkey = lter_table.lterid")
      .where("proj_metadata_key = ?", params[:proj_metadata_key])
    query = query.where('genus = ?', params[:genus]) if params[:genus].present?
    query = query.where('species = ?', params[:species]) if params[:species].present?
    query = query.where('lterid = ?', params[:lterid]) if params[:lterid].present?
    query
  end
end

class Density < ActiveRecord::Base
  self.table_name = 'density_table'
  def self.endpoint(params)
    fields = %w{proj_metadata_key genus species lterid}
    common_cols = %w(authors authors_contact year day month sppcode genus species datatype spatial_replication_level_1_label spatial_replication_level_1 spatial_replication_level_2_label spatial_replication_level_2 spatial_replication_level_3_label spatial_replication_level_3 spatial_replication_level_4_label spatial_replication_level_4 spatial_replication_level_5_label spatial_replication_level_5 proj_metadata_key structure_type_1 structure_type_2 structure_type_3 structure_type_4 density_table.treatment_type_1 density_table.treatment_type_2 density_table.treatment_type_3 covariates density_observation)
    query = select(common_cols.join(', '))
      .joins("JOIN taxa_table  ON density_table.taxa_density_fkey = taxa_table.taxa_table_key")
      .joins("JOIN site_in_project_table ON taxa_table.site_in_project_taxa_key = site_in_project_table.site_in_project_key")
      .joins("JOIN project_table ON site_in_project_table.project_table_fkey = project_table.proj_metadata_key")
      .joins("JOIN study_site_table ON site_in_project_table.study_site_table_fkey = study_site_table.study_site_key")
      .joins("JOIN lter_table ON study_site_table.lter_table_fkey = lter_table.lterid")
      .where("proj_metadata_key = ?", params[:proj_metadata_key])
    query = query.where('genus = ?', params[:genus]) if params[:genus].present?
    query = query.where('species = ?', params[:species]) if params[:species].present?
    query = query.where('lterid = ?', params[:lterid]) if params[:lterid].present?
    query
  end
end

## the actual /search route model that gets called
class Search < ActiveRecord::Base
  def self.endpoint(params)
    params.delete_if { |k, v| v.nil? || v.empty? }
    params = check_limit_offset(params)
    check_proj_metadata_key(params)
    raise Exception.new('limit too large (max 1000)') unless (params[:limit] || 0) <= 1000

    Count.endpoint(params)
      .union_all(Biomass.endpoint(params))
      .union_all(PercentCover.endpoint(params))
      .union_all(Individual.endpoint(params))
      .union_all(Density.endpoint(params))
      .limit(params[:limit] || 100)
      .offset(params[:offset])
  end
end
