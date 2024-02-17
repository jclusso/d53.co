import { Controller } from "@hotwired/stimulus"
import hljs from 'highlight.js/lib/core';
import json from 'highlight.js/lib/languages/json';
import dns from 'highlight.js/lib/languages/dns';

export default class extends Controller {

  connect() {
    hljs.registerLanguage('json', json);
    hljs.registerLanguage('dns', dns);
    hljs.highlightAll();
    this.element.classList.remove('opacity-0')
  }

}
