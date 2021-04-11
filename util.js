.pragma library

function getThoudsandSeperator() {
    return " "
}

function addThousandSeperator(x) {
    return x.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1" + getThoudsandSeperator())
}

function removeThousandSeperator(x) {
    return + x.replace(new RegExp(getThoudsandSeperator(), "gi"), "")
}
