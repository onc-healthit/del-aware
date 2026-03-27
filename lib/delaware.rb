# frozen_string_literal: true

require 'active_support/all'
require 'thor'
require 'fhir_models'
require 'logger'
require 'rainbow'
require 'rest-client'
require 'open3'
require 'time'
require 'json'

require 'delaware/error'
require 'delaware/log'
require 'delaware/version'
require 'delaware/config'

require 'delaware/helpers/content_loader'
require 'delaware/helpers/path_helper'
require 'delaware/helpers/fhir_resource_details'
require 'delaware/helpers/file_loader'

require 'delaware/models/data_element_list'
require 'delaware/models/data_element'
require 'delaware/models/data_requirement'
require 'delaware/models/implementation_guide'
require 'delaware/models/profile'

require 'delaware/services/cqf_tooling'
require 'delaware/services/go_fsh'

require 'delaware/generators/search_parameter'
require 'delaware/generators/capability_statement_server'
require 'delaware/generators/capability_statement_client'
require 'delaware/generators/extension'
require 'delaware/generators/mapping_table'
require 'delaware/generators/profile_intro'
require 'delaware/generators/tag_elements'

# Delaware
module Delaware
  include Log

  autoload :CLI, 'delaware/cli'

  log_info 'Delaware module initialized'
end
