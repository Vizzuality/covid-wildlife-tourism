const MAIN_INPUT_EL: HTMLInputElement = document.querySelector('.js-ownership-input');
const LIST_EL: HTMLSelectElement = document.querySelector('.js-ownership-list');
const FREE_INPUT_EL: HTMLInputElement = document.querySelector('.js-ownership-free-input');
const FREE_INPUT_GROUP_EL = document.querySelector('.js-ownership-free-input-group');

export default class PinsOwnershipField {
  private listValue: string;
  private freeInputValue: string;

  constructor() {
    if (MAIN_INPUT_EL) {
      this.init();
    }
  }

  get showFreeInput() {
    return this.listValue === 'other';
  }

  private updateMainInput() {
    MAIN_INPUT_EL.value = this.showFreeInput ? this.freeInputValue : this.listValue;
  }

  private updateFreeInputVisibility() {
    if (this.showFreeInput) {
      FREE_INPUT_GROUP_EL.removeAttribute('hidden');
    } else {
      FREE_INPUT_GROUP_EL.setAttribute('hidden', 'true');
    }
  }

  private update() {
    this.listValue = LIST_EL.selectedOptions[0].value;
    this.freeInputValue = FREE_INPUT_EL.value;

    this.updateFreeInputVisibility();
    this.updateMainInput();
  }

  private init() {
    LIST_EL.addEventListener('change', this.update.bind(this));

    FREE_INPUT_EL.addEventListener('change', this.update.bind(this));

    // We set the initial values
    this.update();
  }
}
