import subprocess


def main():
    output = ""
    for x in (
        subprocess.check_output(["ipconfig", "getsummary", "en0"]).decode().split("\n")
    ):
        if " SSID" in x:
            output += x.split(" : ")[1] + "\n"
    if output == "":
        return 0
    else:
        for x in subprocess.check_output(["scutil", "--nwi"]).decode().split("\n"):
            if "utun8" in x:
                output += "1"
                return output
        output += "0"
        return output


if __name__ == "__main__":
    print(main())
