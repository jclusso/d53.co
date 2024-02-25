import { Controller } from "@hotwired/stimulus"
import hljs from 'highlight.js/lib/core';
import json from 'highlight.js/lib/languages/json';
import dns from 'highlight.js/lib/languages/dns';

export default class extends Controller {
  static values = { server: String }

  connect() {
    hljs.registerLanguage('json', json);
    hljs.registerLanguage('dns', dns);
    hljs.highlightAll();
    this.#findAndLinkRecords();
    this.element.classList.remove('opacity-0');
  }

  #findAndLinkRecords() {
    let match;
    const spanRegex = /<span class="hljs-string">["']([^"']*)["']<\/span>/g;
    while ((match = spanRegex.exec(this.element.innerHTML)) !== null) {
      this.element.innerHTML = this.element.innerHTML.replace(
        match[0], `<span class="hljs-string">"${this.#recordLink(match[1])}"</span>`
      );
    }

    const numberRegex = /<span class="hljs-number">([^"']*)<\/span>/g;
    while ((match = numberRegex.exec(this.element.innerHTML)) !== null) {
      this.element.innerHTML = this.element.innerHTML.replace(
        match[0], `<span class="hljs-number">${this.#recordLink(match[1])}</span>`
      );
    }

    const domainRegex = /(?<before>\t|\n|\s)(?<domain>[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}\.)(?<after>\s)?/i;
    while ((match = domainRegex.exec(this.element.innerHTML)) !== null) {
      const groups = match.groups;
      this.element.innerHTML = this.element.innerHTML.replace(
        match[0], `${groups.before}${this.#recordLink(groups.domain)}${groups.after}`
      );
    }

    const ipv4Regex = /\s(?:[0-9]{1,3}\.){3}[0-9]{1,3}\s/;
    while ((match = ipv4Regex.exec(this.element.innerHTML)) !== null) {
      this.element.innerHTML = this.element.innerHTML.replace(
        match[0], ` ${this.#recordLink(match[0])} `
      );
    }
  }

  #recordLink(record) {
    const ipv4Regex = /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/;
    const ipv6Regex = /(?:^|(?<=\s))(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))(?=\s|$)/;
    const domainRegex = /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}\.?$/i;
    record = record.replace(/\s/g, '');

    if (ipv4Regex.test(record) || ipv6Regex.test(record)) {
      return `<a href="/${this.serverValue}/ptr/${record.replace(/\.$/, '')}" class="underline hover:no-underline">${record}</a>`;
    } else if (domainRegex.test(record)) {
      return `<a href="/${this.serverValue}/a/${record.replace(/\.$/, '')}" class="underline hover:no-underline">${record}</a>`;
    } else {
      return record;
    }
  }

}
