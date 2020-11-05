const MAIN_INPUT_EL: HTMLInputElement = document.querySelector('.js-enterprise-type-input');
const LIST_EL: HTMLSelectElement = document.querySelector('.js-enterprise-type-list');
const FREE_INPUT_EL: HTMLInputElement = document.querySelector('.js-enterprise-type-free-input');
const FREE_INPUT_GROUP_EL = document.querySelector('.js-enterprise-type-free-input-group');

export default class PinsEnterpriseTypeField {
  private listValues: string[];
  private freeInputValue: string;

  constructor() {
    if (MAIN_INPUT_EL) {
      this.init();
    }
  }

  get showFreeInput() {
    return this.listValues.includes('other');
  }

  private updateMainInput() {
    const values = [
      ...this.listValues.filter(value => value !== 'other'),
      ...(this.showFreeInput ? [this.freeInputValue] : [])
    ];

    MAIN_INPUT_EL.value = values.toString();
  }

  private updateFreeInputVisibility() {
    if (this.showFreeInput) {
      FREE_INPUT_GROUP_EL.removeAttribute('hidden');
      FREE_INPUT_EL.setAttribute('required', 'true');
    } else {
      FREE_INPUT_GROUP_EL.setAttribute('hidden', 'true');
      FREE_INPUT_EL.removeAttribute('required');
    }
  }

  private update() {
    this.listValues = Array.from(LIST_EL.selectedOptions).map(option => option.value);
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
