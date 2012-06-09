//= require active_admin/base
//= require fullcalendar
//= require jquery.rest
//= require calendar
//= require ckeditor-jquery
//= require timer
//= require tickets
//= require ipad
//= require reports

function charge_card() {
  amt = document.getElementById('amount')
  amt.value = amt.value.replace(/[\$,]/g, '')
  to_charge = parseInt(amt.value)
  if (isNaN(to_charge) || to_charge <= 0) {
    alert("Please enter a number greater than 0")
    return false
  }
  return confirm("Are you sure you want to charge $" + to_charge + "?")
}