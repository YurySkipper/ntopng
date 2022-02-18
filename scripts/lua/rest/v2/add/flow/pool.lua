--
-- (C) 2013-22 - ntop.org
--

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path
package.path = dirs.installdir .. "/scripts/lua/modules/pools/?.lua;" .. package.path

local flow_pools = require "flow_pools"
local pools_rest_utils = require "pools_rest_utils"

pools_rest_utils.add_pool(flow_pools)
