# encoding: utf-8

# Test ChangeCD
module Yast
  class SwInputClient < Client
    def main
      Yast.include self, "testsuite.rb"

      # prepare for test:
      # delete packages, because package agent is not yet in testmode, i.e. already
      # installed packages would not installed again

      @cmd = "sudo rpm -e 3d_chess tuxeyes xroach jpilot"
      SCR.Execute(path(".target.bash"), @cmd)

      @user_settings = {}

      @exec_map = { "target" => { "bash" => 0 } }

      @read_map = {
        "run"    => {
          "df" => [
            {
              "dummy" => "on",
              "free"  => "Available",
              "name"  => "Mounted",
              "prz"   => "Capacity",
              "spec"  => "Filesystem",
              "used"  => "Used",
              "whole" => "1024-blocks"
            },
            {
              "free"  => "144988",
              "name"  => "/",
              "prz"   => "93%",
              "spec"  => "/dev/sda1",
              "used"  => "1733600",
              "whole" => "1981000"
            },
            {
              "free"  => "2124147",
              "name"  => "/usr",
              "prz"   => "66%",
              "spec"  => "/dev/sda3",
              "used"  => "4080331",
              "whole" => "6543449"
            }
          ]
        },
        "yast2"  => { "instsource" => { "cdnum" => 1, "cdrelease" => 1234 } },
        "probe"  => {
          "cdrom"        => [{ "dev_name" => "/dev/sr0" }],
          "architecture" => "i386"
        },
        "target" => { "root" => "/" }
      }




      DUMP(
        "TEST 1: argument test_input1 -> install tuxeyes/xroach, userInput true"
      )
      TEST(
        term(:sw_single, path(".test"), "test_input1"),
        [@read_map, {}, @exec_map],
        {}
      )

      DUMP(
        "TEST 2: argument test_input2 -> install 3d_chess, delete  tuxeyes/xroach, userInput false"
      )
      TEST(
        term(:sw_single, path(".test"), "test_input2"),
        [@read_map, {}, @exec_map],
        {}
      )

      @exec_map = { "target" => { "bash" => 1 } }
      DUMP("TEST 3: argument is package jpilot (depAND: pilot-link)")
      TEST(
        term(:sw_single, path(".test"), "jpilot"),
        [@read_map, {}, @exec_map],
        {}
      )

      @exec_map = { "target" => { "bash" => 0 } }
      DUMP(
        "TEST 4: argument path/package.rpm, which means install package without checking deps"
      )
      TEST(
        term(:sw_single, path(".test"), "./gnuchess.rpm"),
        [@read_map, {}, @exec_map],
        {}
      )

      DUMP(
        "TEST 5: without .test -> popup packager error because can't read rpm database (not root)"
      )
      TEST(term(:sw_single, "./gnuchess.rpm"), [@read_map, {}, @exec_map], {})

      nil
    end
  end
end

Yast::SwInputClient.new.main
