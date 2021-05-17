--
-- (C) 2019-21 - ntop.org
--

-- ##############################################

local host_alert_keys = require "host_alert_keys"
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

local alert_creators = require "alert_creators"
local json = require("dkjson")
-- Import the classes library.
local classes = require "classes"
-- Make sure to import the Superclass!
local alert = require "alert"

-- ##############################################

local host_alert_score_anomaly = classes.class(alert)

-- ##############################################

host_alert_score_anomaly.meta = {
  alert_key = host_alert_keys.host_alert_score_anomaly,
  i18n_title = "alerts_dashboard.score_anomaly",
  icon = "fas fa-fw fa-life-ring",
  has_attacker = true,
}

-- ##############################################

-- @brief Prepare an alert table used to generate the alert
-- @return A table with the alert built
function host_alert_score_anomaly:init()
   -- Call the parent constructor
   self.super:init()

   self.alert_type_params = {}
end

-- ##############################################

-- @brief Local function used to get the most inpactant category for the score
-- @return The score category
local function get_problematic_category(alert_type_params, is_both, is_client_or_srv)
   local score_category_network  = 0
   local score_category_security = 0
   local tot                     = 0

   if is_both then
      score_category_network = alert_type_params["score_breakdown_client_0"] +
	 alert_type_params["score_breakdown_server_0"]
      score_category_security = alert_type_params["score_breakdown_client_1"] +
	 alert_type_params["score_breakdown_server_1"]
      
      tot = score_category_network + score_category_security
   else
      score_category_network = alert_type_params["score_breakdown_" .. is_client_or_srv .. "_0"]
      score_category_security = alert_type_params["score_breakdown_" .. is_client_or_srv .. "_1"]
      tot = score_category_network + score_category_security
   end

   if(tot > 0) then
      score_category_network  = (score_category_network*100)/tot
      score_category_security = 100 - score_category_network
   end

   return score_category_network, score_category_security
end

-- #######################################################

-- @brief Format an alert into a human-readable string
-- @param ifid The integer interface id of the generated alert
-- @param alert The alert description table, including alert data such as the generating entity, timestamp, granularity, type
-- @param alert_type_params Table `alert_type_params` as built in the `:init` method
-- @return A human-readable string
function host_alert_score_anomaly.format(ifid, alert, alert_type_params)
  local alert_consts = require("alert_consts")
  local is_client_alert = alert_type_params["is_client_alert"]
  local is_both = alert_type_params["is_both"]
  local role
  local host = alert_consts.formatHostAlert(ifid, alert["ip"], alert["vlan_id"])
  local sec_cat = 0
  local net_cat = 0
  
  if(is_both) then
     role = "client and server"
     net_cat, sec_cat = get_problematic_category(alert_type_params, true)
  elseif(is_client_alert) then
     role = "client"
     net_cat, sec_cat = get_problematic_category(alert_type_params, nil, "client")
  else
     role = "server"
     net_cat, sec_cat = get_problematic_category(alert_type_params, nil, "server")
  end
  
  return i18n("alert_messages.score_number_anomaly", {
		 role = role,
		 host = host,
		 score = alert_type_params["value"],
		 lower_bound = alert_type_params["lower_bound"],
		 upper_bound = alert_type_params["upper_bound"],
		 network = net_cat,
		 security = sec_cat,
  })
end

-- #######################################################

return host_alert_score_anomaly
