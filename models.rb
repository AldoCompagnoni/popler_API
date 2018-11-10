require 'active_record_union'


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


class Biomass < ActiveRecord::Base
  self.table_name = 'biomass_table'

  def self.endpoint(params)
    params.delete_if { |k, v| v.nil? || v.empty? }
    params = check_limit_offset(params)
    raise Exception.new('limit too large (max 1000)') unless (params[:limit] || 0) <= 1000
    # select
      # .order('species')
    limit(params[:limit] || 10)
      .offset(params[:offset])
  end
end

class Search < ActiveRecord::Base
  self.table_name = 'count_table'

  def self.endpoint(params)
    params.delete_if { |k, v| v.nil? || v.empty? }
    params = check_limit_offset(params)
    raise Exception.new('limit too large (max 1000)') unless (params[:limit] || 0) <= 1000

    # FIXME: for some reason treatment_type_* fields cause problems, not sure why, remnoved for now
    common_cols = %w(authors authors_contact year day month sppcode genus species datatype spatial_replication_level_1_label spatial_replication_level_1 spatial_replication_level_2_label spatial_replication_level_2 spatial_replication_level_3_label spatial_replication_level_3 spatial_replication_level_4_label spatial_replication_level_4 spatial_replication_level_5_label spatial_replication_level_5 proj_metadata_key structure_type_1 structure_type_2 structure_type_3 structure_type_4 covariates count_observation)
    # cols1 = %w(treatment_type_1 treatment_type_2 treatment_type_3 covariates count_observation)
    
    # select(common_cols.join(', ') + ', ' + cols1.join(', '))
    select(common_cols.join(', '))
      .joins("JOIN taxa_table ON count_table.taxa_count_fkey = taxa_table.taxa_table_key")
      .joins("JOIN site_in_project_table ON taxa_table.site_in_project_taxa_key = site_in_project_table.site_in_project_key")
      .joins("JOIN project_table ON site_in_project_table.project_table_fkey = project_table.proj_metadata_key")
      .joins("JOIN study_site_table ON site_in_project_table.study_site_table_fkey = study_site_table.study_site_key")
      .joins("JOIN lter_table ON study_site_table.lter_table_fkey = lter_table.lterid")
      .where(sprintf("proj_metadata_key = %s", params[:proj_metadata_key]))
      .limit(params[:limit] || 10)
      .offset(params[:offset])
  end
end
