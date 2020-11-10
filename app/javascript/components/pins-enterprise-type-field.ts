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

  private restore() {
    if (!MAIN_INPUT_EL.value) {
      return;
    }

    const values = MAIN_INPUT_EL.value.split(',');
    Array.from(LIST_EL.options).forEach((option) => {
      const index = values.findIndex(value => value === option.value);
      if (index > -1) {
        option.selected = true;
        values.splice(index, 1);
      }
    });

    // If we still have some values, it's because the user clicked “Other” and added their own
    // enterprise type(s)
    if (values.length > 0) {
      Array.from(LIST_EL.options).find(option => option.value === 'other').selected = true;
      FREE_INPUT_EL.value = values.join(',');
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

    // We restore the state of the inputs
    this.restore();

    // We set the initial values
    this.update();
  }
}
