// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import VegaLite from "./vegalite"
import Sortable from "../vendor/sortable"
import InfiniteScroll from "./infinite_scroll"


let hooks = {VegaLite, InfiniteScroll}

hooks.Sortable = {
  mounted() {
    let group = this.el.dataset.group
    let sorter = new Sortable(this.el, {
      group: group ? group : undefined,
      animation: 150,
      delay: 100,
      dragClass: "drag-item",
      ghostClass: "drag-ghost",
      forceFallback: true,
      onEnd: e => {
        let params = {old: e.oldIndex, new: e.newIndex, to: e.to.dataset, ...e.item.dataset}
        this.pushEventTo(this.el, "swap", params)
      }
    })
  }
}

hooks.Copy = {
  mounted() {
    let { to } = this.el.dataset;
    this.el.addEventListener("click", (ev) => {
      ev.preventDefault();
      let text = document.querySelector(to).value
      navigator.clipboard.writeText(text).then(() => {
        console.log("All done again!")
      })
    });
  },
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks})

topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

liveSocket.connect()
window.liveSocket = liveSocket

