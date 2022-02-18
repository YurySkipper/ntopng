--
-- (C) 2020-22 - ntop.org
--

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"
local alert_entities = require "alert_entities"
local alert_consts = require "alert_consts"
local alert_severities = require "alert_severities"
local alert_utils = require "alert_utils"

local tag_utils = {}

-- Operator Separator in query strings
tag_utils.SEPARATOR = alert_utils.SEPARATOR

-- #####################################

-- Supported operators
tag_utils.tag_operators = {
    ["eq"]  = "=",
    ["neq"] = "!=",
    ["lt"]  = "<",
    ["gt"]  = ">",
    ["gte"] = ">=",
    ["lte"] = "<=",
    ["in"]  = i18n("has"),
    ["nin"] = i18n("does_not_have"),
}

-- #####################################

tag_utils.defined_tags = {
   alert_id = {
      value_type = 'alert_id',
      i18n_label = i18n('db_search.tags.alert_id'),
      operators = {'eq','neq'}
   },
   l7proto = {
      value_type = 'l7_proto',
      i18n_label = i18n('db_search.tags.l7_proto'),
      operators = {'eq', 'neq'}
   },
   l7proto_master = {
      value_type = 'l7_proto',
      i18n_label = i18n('db_search.tags.l7_proto'),
      operators = {'eq', 'neq'},
      hide = true,
   },
   l7cat = {
      value_type = 'l7_category',
      i18n_label = i18n('db_search.tags.l7cat'),
      operators = {'eq', 'neq'}
   },
   flow_risk = {
      value_type = 'flow_risk',
      i18n_label = i18n('db_search.tags.flow_risk'),
      operators = {'eq', 'neq', 'in', 'nin'}
   },
   status = {
      value_type = 'alert_type',
      i18n_label = i18n('db_search.tags.status'),
      operators = {'eq', 'neq'}
   },
   l4proto = {
      value_type = 'l4_proto',
      i18n_label = i18n('db_search.tags.l4proto'),
      operators = {'eq', 'neq'},
      bpf_key = 'ip proto',
   },
   ip_version = {
      value_type = 'ip_version',
      i18n_label = i18n('db_search.tags.ip_version'),
      operators = {'eq','neq'},
   },
   ip = {
      value_type = 'ip',
      i18n_label = i18n('db_search.tags.ip'),
      operators = {'eq', 'neq'},
      bpf_key = 'ip host',
   },
   cli_ip = {
      value_type = 'ip',
      i18n_label = i18n('db_search.tags.cli_ip'),
      operators = {'eq', 'neq'},
      bpf_key = 'ip host',
   },
   cli_location = {
      value_type = 'location',
      i18n_label = i18n('db_search.tags.cli_location'),
      operators = {'eq', 'neq'}
   },
   srv_ip = {
      value_type = 'ip',
      i18n_label = i18n('db_search.tags.srv_ip'),
      operators = {'eq', 'neq'},
      bpf_key = 'ip host',
   },
   srv_location = {
      value_type = 'location',
      i18n_label = i18n('db_search.tags.srv_location'),
      operators = {'eq', 'neq'}
   },
   name = {
      value_type = 'hostname',
      i18n_label = i18n('db_search.tags.name'),
      operators = {'eq','neq', 'in', 'nin'},
   },
   cli_name = {
      value_type = 'hostname',
      i18n_label = i18n('db_search.tags.cli_name'),
      operators = {'eq', 'neq', 'in', 'nin'}
   },
   srv_name = {
      value_type = 'hostname',
      i18n_label = i18n('db_search.tags.srv_name'),
      operators = {'eq', 'neq', 'in', 'nin'}
   },
   network_name = {
      value_type = 'text',
      i18n_label = i18n('db_search.tags.network_name'),
      operators = {'eq','neq'},
   },
   src2dst_dscp = {
      value_type = 'dscp_type',
      i18n_label = i18n('db_search.tags.src2dst_dscp'),
      operators = {'eq', 'neq'}
   },
   dst2src_dscp = {
      value_type = 'dscp_type',
      i18n_label = i18n('db_search.tags.dst2src_dscp'),
      operators = {'eq', 'neq'}
   },
   cli_port = {
      value_type = 'port',
      i18n_label = i18n('db_search.tags.cli_port'),
      operators = {'eq', 'neq', 'lt', 'gt', 'gte', 'lte'},
      bpf_key = 'port',
   },
   srv_port = {
      value_type = 'port',
      i18n_label = i18n('db_search.tags.srv_port'),
      operators = {'eq', 'neq', 'lt', 'gt', 'gte', 'lte'},
      bpf_key = 'port',
   },
   cli_asn = {
      value_type = 'asn',
      i18n_label = i18n('db_search.tags.cli_asn'),
      operators = {'eq', 'neq'}
   },
   srv_asn = {
      value_type = 'asn',
      i18n_label = i18n('db_search.tags.srv_asn'),
      operators = {'eq', 'neq'}
   },
   cli_nw_latency = {
      value_type = 'nw_latency_type',
      i18n_label = i18n('db_search.tags.cli_nw_latency'),
      operators = {'eq', 'lt', 'gt', 'lte', 'gte'}
   },
   srv_nw_latency = {
      value_type = 'nw_latency_type',
      i18n_label = i18n('db_search.tags.srv_nw_latency'),
      operators = {'eq', 'lt', 'gt', 'lte', 'gte'}
   },
   observation_point_id = {
      value_type = 'observation_point_id',
      i18n_label = i18n('db_search.tags.observation_point_id'),
      operators = {'eq', 'neq'}
   },
   probe_ip = {
      value_type = 'ip',
      i18n_label = i18n('db_search.tags.probe_ip'),
      operators = {'eq', 'neq'}
   },
   vlan_id = {
      value_type = 'id',
      i18n_label = i18n('db_search.tags.vlan_id'),
      operators = {'eq', 'neq', 'lt', 'gt', 'gte', 'lte'}
   },
   input_snmp = {
      value_type = 'snmp_interface',
      i18n_label = i18n('db_search.tags.input_snmp'),
      operators = {'eq', 'neq'}
   },
   output_snmp = {
      value_type = 'snmp_interface',
      i18n_label = i18n('db_search.tags.output_snmp'),
      operators = {'eq', 'neq'}
   },
   src2dst_tcp_flags = {
      value_type = 'flags',
      i18n_label = i18n('db_search.src2dst_tcp_flags'),
      operators = {'eq', 'neq', 'in', 'nin'}
   },
   dst2src_tcp_flags = {
      value_type = 'flags',
      i18n_label = i18n('db_search.dst2src_tcp_flags'),
      operators = {'eq', 'neq', 'in', 'nin'}
   },
   severity = {
      value_type = 'severity',
      i18n_label = i18n('db_search.tags.severity'),
      operators = {'eq','lte','gte','neq'},
   },
   score = {
      value_type = 'score',
      i18n_label = i18n('db_search.tags.score'),
      operators = {'eq', 'neq','lt', 'gt', 'gte', 'lte'}
   },
   cli_mac = {
      value_type = 'mac',
      i18n_label = i18n('db_search.tags.cli_mac'),
      operators = {'eq', 'neq'},
      bpf_key = 'ether host',
   },
   srv_mac = {
      value_type = 'mac',
      i18n_label = i18n('db_search.tags.srv_mac'),
      operators = {'eq', 'neq'},
      bpf_key = 'ether host',
   },
   cli_network = {
      value_type = 'network_id',
      i18n_label = i18n('db_search.tags.cli_network'),
      operators = {'eq', 'neq'}
   },
   srv_network = {
      value_type = 'network_id',
      i18n_label = i18n('db_search.tags.srv_network'),
      operators = {'eq', 'neq'}
   },
   info = {
      value_type = 'text',
      i18n_label = i18n('db_search.tags.info'),
      operators = {'eq', 'neq', 'in', 'nin'}
   },
   bytes = {
      value_type = 'bytes',
      i18n_label = i18n('db_search.tags.bytes'),
      operators = {'eq', 'neq', 'lt', 'gt', 'gte', 'lte'}
   },
   packets = {
      value_type = 'packets',
      i18n_label = i18n('db_search.tags.packets'),
      operators = {'eq', 'neq', 'lt', 'gt', 'gte', 'lte'}
   },
   cli_host_pool_id = {
      value_type = 'host_pool_id',
      i18n_label = i18n('db_search.tags.cli_host_pool_id'),
      operators = {'eq', 'neq', 'lt', 'gt', 'gte', 'lte'}
   },
   srv_host_pool_id = {
      value_type = 'host_pool_id',
      i18n_label = i18n('db_search.tags.srv_host_pool_id'),
      operators = {'eq', 'neq', 'lt', 'gt', 'gte', 'lte'}
   },
   subtype = {
      value_type = 'text',
      i18n_label = i18n('db_search.tags.subtype'),
      operators = {'eq', 'neq'},
   },
   role = {
      value_type = 'role',
      i18n_label = i18n('db_search.tags.role'),
      operators = {'eq'},
   },
   role_cli_srv = {
      value_type = 'role_cli_srv',
      i18n_label = i18n('db_search.tags.role_cli_srv'),
      operators = {'eq'},
   },
}

-- #####################################

tag_utils.ip_location = {
   { label = "Remote", id = 0 },
   { label = "Local",  id = 1 },
   { label = "Multicast", id = 2},
}

-- #####################################

function tag_utils.get_tag_filters_from_request()
   local filters = {}

   for key, value in pairs(tag_utils.defined_tags) do
      if _GET[key] ~= nil then
         filters[key] = _GET[key]
      end
   end

   if not isEmptyString(filters['l7proto']) then
      if not tonumber(l7proto) then
         filters['l7proto'] = interface.getnDPIProtoId(filters['l7proto'])
      end
   end

   return filters
end

-- ##############################################

--@brief Evaluate operator
function tag_utils.eval_op(v1, op, v2)
   local default_verdict = true

   -- Convert boolean for compatibility
   if type(v1) == 'boolean' then
      if v1 then v1 = 1 else v1 = 0 end
   end

   if not v1 or not v2 then
      return default_verdict
   end

   if op == 'eq' then
      return v1 == v2
   elseif op == 'neq' then
      return v1 ~= v2
   elseif op == 'lt' then
      return v1 < v2
   elseif op == 'gt' then
      return v1 > v2
   elseif op == 'gte' then
      return v1 >= v2
   elseif op == 'lte' then
      return v1 <= v2
   elseif op == 'in' then
      v_and = v1 & v2
      return v1 == v_and
   elseif op == 'nin' then
      v_and = v1 & v2
      return v1 ~= v_and
   end 

   return default_verdict
end

-- #####################################

tag_utils.formatters = {
   l4proto = function(proto) return l4_proto_to_string(proto) end,
   l7_proto = function(proto) return interface.getnDPIProtoName(tonumber(proto)) end,
   l7proto  = function(proto) return interface.getnDPIProtoName(tonumber(proto)) end, 
   l7cat = function(cat) return interface.getnDPICategoryName(tonumber(cat)) end,
   severity = function(severity) return (i18n(alert_consts.alertSeverityById(tonumber(severity)).i18n_title)) end,
   status = function(status) return alert_consts.alertTypeLabel(status, true, alert_entities.flow.entity_id) end,
   role = function(role) return (i18n(role)) end,
   role_cli_srv = function(role) return (i18n(role)) end,
   flow_risk = function(risk) 
      local flow_risk_list = ntop.getRiskList() or {}
      flow_risk_list[1] = i18n("flow_risk.ndpi_no_risk")
      return flow_risk_list[tonumber(risk)+1] or risk 
   end,
}

-- ######################################

function tag_utils.get_tag_info(id)
   local tag = tag_utils.defined_tags[id]

   if tag == nil then
     -- traceError(TRACE_WARNING, TRACE_CONSOLE, "Tag " .. id .. " not found")
     return nil
   end

   local filter = {
      id = id,
      label = tag.i18n_label,
      value_type = tag.value_type,
      value_label = tag.value_i18n_label or tag.i18n_label,
      operators = {}
   }

   for _, op in ipairs(tag.operators) do
      filter.operators[#filter.operators+1] = {
         id = op,
         label = tag_utils.tag_operators[op],
      }
   end

   -- select (array of values)
   if tag.value_type == "l7_proto" then
      filter.value_type = 'array'
      filter.options = {}
      local l7_protocols = interface.getnDPIProtocols()
      for name, id in pairsByKeys(l7_protocols, asc) do
         filter.options[#filter.options+1] = { value = id, label = name, }
      end
   elseif tag.value_type == "ip_version" then
      filter.value_type = 'array'
      filter.options = {}
      filter.options[#filter.options+1] = { value = "4", label = i18n("ipv4"), }
      filter.options[#filter.options+1] = { value = "6", label = i18n("ipv6"), }
   elseif tag.value_type == "role" then
      filter.value_type = 'array'
      filter.options = {}
      filter.options[#filter.options+1] = { value = "attacker", label = i18n("attacker"), }
      filter.options[#filter.options+1] = { value = "victim",   label = i18n("victim"),   }
      filter.options[#filter.options+1] = { value = "no_attacker_no_victim", label = i18n("no_attacker_no_victim"),
      }
   elseif tag.value_type == "role_cli_srv" then
      filter.value_type = 'array'
      filter.options = {}
      filter.options[#filter.options+1] = { value = "client", label = i18n("client"), }
      filter.options[#filter.options+1] = { value = "server", label = i18n("server"), }
   elseif tag.value_type == "severity" then
      filter.value_type = 'array'
      filter.options = {}
      local severities = alert_severities
      for _, severity in pairsByValues(severities, alert_utils.severity_rev) do
         filter.options[#filter.options+1] = {
            value = severity.severity_id,
            label = i18n(severity.i18n_title),
         }
      end
   end

   return filter
end

-- ######################################

function tag_utils.add_tag_if_valid(tags, tag_key, operators, i18n_prefix)
   if isEmptyString(_GET[tag_key]) then
      return
   end

   local get_value = _GET[tag_key]
   local list = split(get_value, ',')

   for _,item in ipairs(list) do
      local selected_operator = 'eq'

      local splitted = split(item, tag_utils.SEPARATOR)

      local realValue
      if #splitted == 2 then
         realValue = splitted[1]
         selected_operator = splitted[2]
      end

      local value = realValue
      if tag_utils.formatters[tag_key] ~= nil then
         value = tag_utils.formatters[tag_key](value)
      end

      tag = {
         realValue = realValue,
         value = value,
         label = i18n(i18n_prefix .. "." .. tag_key),
         key = tag_key,
         operators = operators,
         selectedOperator = selected_operator
      }

      table.insert(tags, tag)
   end
end

-- #####################################

function tag_utils.build_bpf(filters)
   local bpf = ""

   local n = 0

   local and_tags = {}
   local or_tags = {}

   -- Build 'or' groups (same key)
   for key, _value in pairs(filters) do

      if not tag_utils.defined_tags[key] then
         goto skip_filter
      end
      local bpf_key = tag_utils.defined_tags[key].bpf_key

      if not bpf_key then
         goto skip_filter
      end

      local list = split(_value, ',')

      for _,value in ipairs(list) do
         local op = "eq" -- default
         local bpf_val = value

         -- tags has value formatted in this way: (e.g.) cli_port = 888,eq
         -- it means, search for values with port == 888
         local splitted_value = split(value, tag_utils.SEPARATOR)

         if table.len(splitted_value) == 2 then
            op = splitted_value[2]
            bpf_val = splitted_value[1]
         end

         local version = 4
         if key:ends('ip') then -- either cli_ip, srv_ip or ip (for both)
            version = isIPv6(bpf_val) and 6 or 4
         end

         if key == "l4proto" and bpf_val and not tonumber(bpf_val) then
            bpf_val = l4_proto_to_id(bpf_val)
         end

         -- Fetch the clickhouse key

         if op ~= "eq" and op ~= "neq" then
            goto continue
         end

         local cond = bpf_key .. ' ' .. bpf_val

         if op == "neq" then
            cond = 'not' .. ' ' .. cond
         end

         if op == "neq" then -- All 'neq' with the same key are in 'and'
            if and_tags[key] then
               and_tags[key] = and_tags[key] .. " AND " .. cond
            else
               and_tags[key] = cond
            end
         else -- All other operators with the same key are in 'or'
            if or_tags[key] then
               or_tags[key] = or_tags[key] .. " OR " .. cond
            else
               or_tags[key] = cond
            end
         end

         n = n + 1

         ::continue::
      end

      ::skip_filter::
   end

   if n == 0 then
      return bpf
   end

   -- Join all groups with 'and'

   -- AND groups
   for key, value in pairs(and_tags) do
      if isEmptyString(bpf) then
         bpf = "(" .. value .. ")"
      else
         bpf = bpf .. " and " .. "(" .. value .. ")"
      end
   end

   -- OR groups
   for key, value in pairs(or_tags) do
      if isEmptyString(bpf) then
         bpf = "(" .. value .. ")"
      else
         bpf = bpf .. " or " .. "(" .. value .. ")"
      end
   end

   return bpf
end

-- #####################################

return tag_utils
