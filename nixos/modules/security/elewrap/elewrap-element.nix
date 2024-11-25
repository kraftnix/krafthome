# from elewrap upstream
{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    literalExpression
    mkOption
    types
    ;
in {
  options = {
    path = mkOption {
      type = types.str;
      readOnly = true;
      default = "/run/wrappers/bin/elewrap-${config._module.args.name}";
      description = ''
        The resulting wrapper that may be executed by the allowed users and groups
        to run the given command with elevated permissions.
      '';
    };

    command = mkOption {
      type = types.listOf (types.either types.str types.path);
      example = literalExpression ''["''${pkgs.lm_sensors}/bin/sensors"]'';
      description = ''
        The command that is executed after elevating privileges.
        May include arguments. The first element (the executable) must be a path.
      '';
    };

    targetUser = mkOption {
      type = types.str;
      example = "root";
      description = "The user to change to before executing the command.";
    };

    allowedUsers = mkOption {
      default = [];
      example = ["user1" "user2"];
      type = types.listOf types.str;
      description = "The users allowed to execute this wrapper.";
    };

    allowedGroups = mkOption {
      default = [];
      example = ["group1" "group2"];
      type = types.listOf types.str;
      description = "The groups allowed to execute this wrapper.";
    };

    passEnvironment = mkOption {
      default = [];
      type = types.listOf types.str;
      description = "The environment variables in this list will be allowed to be passed to the target command. Anything else will be erased.";
    };

    passArguments = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Whether any given arguments should be appended to the target command.
        This will be added to any static arguments given in the command, if any.
      '';
    };

    verifySha512 = mkOption {
      default = true;
      type = types.bool;
      description = "Whether to verify the sha512 of the target executable at runtime before executing it.";
    };
  };
}
