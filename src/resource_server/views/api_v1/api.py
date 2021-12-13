from flask import current_app, jsonify, request
from flask_tern import openapi
from flask_tern.auth import current_user, require_user

from resource_server.views.api_v1.blueprint import bp
from resource_server.utils.cmd import execute_command, load_template_values
from resource_server.utils.common import paramiko_establish_connection, validate_schema, create_request_param_to_config


@bp.route("/cmd/<endpoint>", methods=["GET", "POST"])
@require_user
@openapi.validate()
def cmd(endpoint):

    path_file = current_app.config["CMD_PATH_FILE"]
    base_url = current_app.config["SSH_KEYSIGN_BASE_URL"]
    user = current_user.claims[current_app.config["SSH_PRINCIPAL_CLAIM"]]


    if request.method == 'POST':
        params = request.json
    elif request.method == 'GET':
        params = request.args 
    else: 
        params = dict()
    
    request_params = create_request_param_to_config(params)

    # If the schema validator does raise any error then load the right endpoint values
    command = load_template_values(validate_schema(path_file), endpoint, request_params)

    # Check the app env and get the mocking server port
    if current_app.config["TESTING"]:
        command["port"] = params.get("ssh_port")

    ssh = paramiko_establish_connection(base_url, user, command["host"], command["port"], request.headers)
    response = execute_command(ssh, command, request.method)
    return jsonify(response)
