defmodule RealDealApiWeb.Auth.ErrorResponse.Unauthorized do
    defexception [message: "unauthorized", plug_status: 401]
end

defmodule RealDealApiWeb.Auth.ErrorResponse.Forbidden do
    defexception [message: "forbidden", plug_status: 403]
end

defmodule RealDealApiWeb.Auth.ErrorResponse.NotFound do
    defexception [message: "not found", plug_status: 404]
end