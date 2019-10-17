// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

window.handle_language_change = function(event) {
  var source_language_select = this.document.querySelector("#translation_source_language");
  var destination_language_select = this.document.querySelector("#translation_destination_language");

  this.console.log(source_language_select.value);

  if (source_language_select.value == "ruby") {
    destination_language_select.value = "js";
  } else {
    destination_language_select.value = "ruby";
  }

  this.document.querySelector("#translation_source_code").value = ""
  this.document.querySelector("#translation_destination_code").innerHTML = ""

  this.document.querySelector("#translation_source_output").innerHTML = ""
  this.document.querySelector("#translation_destination_output").innerHTML = ""
}
