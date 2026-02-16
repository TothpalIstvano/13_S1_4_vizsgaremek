<template>
  <div class="wrapper">
    <div class="card-form">
      <div class="card-list">
        <div class="card-item" :class="{ '-active': isCardFlipped }">
          <div class="card-item__side -front">
            <div class="card-item__cover">
              <img :src="cardBg" class="card-item__bg" />
            </div>
            <div class="card-item__wrapper">
              <div class="card-item__top">
                <img
                  src="https://raw.githubusercontent.com/muhammederdem/credit-card-form/master/src/assets/images/chip.png"
                  class="card-item__chip"
                />
                <div class="card-item__type">
                  <img
                    v-if="cardTypeImg"
                    :src="cardTypeImg"
                    class="card-item__typeImg"
                    alt="Card type"
                  />
                </div>
              </div>

              <label class="card-item__number">
                <span v-for="(n, i) in maskedCardNumber" :key="i">
                  <span class="card-item__numberItem">{{ n }}</span>
                </span>
              </label>

              <div class="card-item__content">
                <label class="card-item__info">
                  <div class="card-item__holder">Card Holder</div>
                  <div class="card-item__name">
                    <span
                      class="card-item__nameItem"
                      v-for="(char, index) in formattedCardName"
                      :key="index"
                    >
                      {{ char }}
                    </span>
                  </div>
                </label>

                <div class="card-item__date">
                  <label class="card-item__dateTitle">Expires</label>
                  <span class="card-item__dateItem">{{ cardMonth || 'MM' }}</span>
                  /
                  <span class="card-item__dateItem">{{
                    cardYear ? cardYear.toString().slice(2) : 'YY'
                  }}</span>
                </div>
              </div>
            </div>
          </div>

          <div class="card-item__side -back">
            <div class="card-item__cover">
              <img :src="cardBg" class="card-item__bg" />
            </div>
            <div class="card-item__band"></div>
            <div class="card-item__cvv">
              <div class="card-item__cvvTitle">CVV</div>
              <div class="card-item__cvvBand">
                <span v-for="n in cardCvv.length" :key="n">*</span>
              </div>
              <div class="card-item__type">
                <img :src="cardTypeImg" v-if="cardTypeImg" class="card-item__typeImg" />
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="card-form__inner">
        <div class="card-input">
          <label class="card-input__label">Card Number</label>
            <input
            v-model="cardNumber"
            @input="formatCardNumber"
            @focus="flipCard(false)"
            class="card-input__input"
            placeholder="0000 0000 0000 0000"
            :maxlength="cardType === 'amex' ? 17 : 19"
            />
        </div>

        <div class="card-input">
          <label class="card-input__label">Card Holder</label>
            <input
            v-model="cardName"
            @focus="flipCard(false)"
            class="card-input__input"
            placeholder="FULL NAME"
            @input="cardName = ($event.target as HTMLInputElement).value
                .replace(/((?:[^-]*?-){2}[^-]*?)-/g, '$1')
                .toUpperCase()" 
            maxlength="25"
            />
        </div>

        <div class="card-form__row">
          <div class="card-form__col">
            <label class="card-input__label">Expiration Date</label>
            <div class="card-form__group">
              <select v-model="cardMonth" class="card-input__input">
                <option value="" disabled>Month</option>
                <option v-for="n in 12" :key="n" :value="minMonth + n - 1">
                  {{ minMonth + n - 1 }}
                </option>
              </select>
              <select v-model="cardYear" class="card-input__input">
                <option value="" disabled>Year</option>
                <option
                  v-for="n in 7"
                  :key="n"
                  :value="minYear + n - 1"
                >
                  {{ minYear + n - 1}}
                </option>
              </select>
            </div>
          </div>

          <div class="card-form__col -cvv">
            <div class="card-input">
              <label class="card-input__label">CVV</label>
              <input
                v-model="cardCvv"
                @input="cardCvv = cardCvv.replace(/\D/g, '').slice(0, cardType === 'amex' ? 4 : 3)"
                @focus="flipCard(true)"
                @blur="flipCard(false)"
                class="card-input__input"
                :maxlength="cardType === 'amex' ? 4 : 3"
                :placeholder="cardType === 'amex' ? '1234' : '123'"
              />
            </div>
          </div>
        </div>
        <div>
        </div>
        <button @click="submit" class="card-form__button" type="submit">Submit</button>
      </div>
    </div>

    <!-- Overlay -->
    <div v-if="showOverlay" class="overlay">
      <div class="overlay-content">
        <p>{{ overlayMessage }}</p>
        <button @click="closeOverlay" class="overlay-button">Close</button>
      </div>
    </div>
  </div>
</template>
<script lang="ts" setup>
import { ref, computed, nextTick, inject } from 'vue';
import axios from 'axios';
import router from '@/router/router';

const cardNumber = ref('');
const cardName = ref('');
const cardMonth = ref('');
const cardYear = ref('');
const cardCvv = ref('');
const isCardFlipped = ref(false);
const showOverlay = ref(false);
const overlayMessage = ref('');

const minYear = new Date().getFullYear();
const minMonth = new Date().getMonth() + 1;

// Read order payload persisted by Kosar (sessionStorage)
const stored = typeof window !== 'undefined' ? sessionStorage.getItem('orderPayload') : null;
const orderPayload = ref(stored ? JSON.parse(stored) : null);

console.log('orderPayload loaded', orderPayload);
// Single cardType computed property
const cardType = computed(() => {
  const num = cardNumber.value.replace(/\D/g, ''); // Clean number for detection
  if (/^4/.test(num)) return 'visa';
  if (/^3[47]/.test(num)) return 'amex';
  if (/^5[1-5]/.test(num)) return 'mastercard';
  if (/^6011/.test(num)) return 'discover';
  if (/^9792/.test(num)) return 'troy';
  return 'visa';
});

const cardTypeImg = computed(() =>
  cardType.value
    ? `https://raw.githubusercontent.com/muhammederdem/credit-card-form/master/src/assets/images/${cardType.value}.png`
    : ''
);

const cardBg = computed(() =>
  `https://raw.githubusercontent.com/muhammederdem/credit-card-form/master/src/assets/images/${Math.floor(Math.random() * 25 + 1)}.jpeg`
);

const cardMask = computed(() =>
  cardType.value === 'amex' ? '#### ###### #####' : '#### #### #### ####'
);

const maskedCardNumber = computed(() => {
  const cleaned = cardNumber.value.replace(/\D/g, '');
  const mask = cardMask.value;
  let i = 0;
  return mask.split('').map(c => c === '#' ? cleaned[i++] || '#' : c);
});

const formattedCardName = computed(() => cardName.value || 'FULL NAME');

function flipCard(status: boolean) {
  isCardFlipped.value = status;
}

const formatCardNumber = async (event: Event) => {
  const input = event.target as HTMLInputElement;
  let value = input.value.replace(/\D/g, '');
  let formatted = '';
  
  const isAmex = cardType.value === 'amex';
  
  if (isAmex) {
    value = value.slice(0, 15);
    formatted = value
      .replace(/(\d{4})(\d{0,6})(\d{0,5})/, (_, p1, p2, p3) => 
        [p1, p2, p3].filter(Boolean).join(' ')
      );
  } else {
    value = value.slice(0, 16);
    formatted = value.replace(/(\d{4})(?=\d)/g, '$1 ');
  }

  cardNumber.value = formatted;
  
  await nextTick();
  const caretPosition = input.selectionStart;
  if (caretPosition !== null && formatted.length > input.value.length) {
    input.setSelectionRange(caretPosition + 1, caretPosition + 1);
  }
};

const submit = async () => {
  if (
    cardNumber.value &&
    cardName.value.length >= 8 &&
    cardMonth.value &&
    cardYear.value &&
    cardCvv.value
  ) {
    overlayMessage.value = 'Card accepted!';
    showOverlay.value = true;
    console.log('submitting order', orderPayload.value);
    await submitOrder(orderPayload.value);

    // Reset form fields
    cardNumber.value = '';
    cardName.value = '';
    cardMonth.value = '';
    cardYear.value = '';
    cardCvv.value = '';
    isCardFlipped.value = false;
  } else {
    overlayMessage.value = 'Please fill all fields correctly.';
    showOverlay.value = true;
  }
};

const closeOverlay = () => {
  showOverlay.value = false;
};

async function submitOrder(orderData) {
    if (!orderData) {
      overlayMessage.value = 'Nincs rendelési adat. Kérlek térj vissza a kosárhoz.';
      showOverlay.value = true;
      return;
    }

    // Transform to API format: { termekek: [{termek_id, mennyiseg, szin_id}], felhasznalo_id }
    const apiPayload = {
      felhasznalo_id: null,
      termekek: (orderData.items || orderData.termekek || []).map(i => ({
        termek_id: i.termek_id ?? i.id,
        mennyiseg: i.mennyiseg ?? i.quantity ?? i.mennyiseg ?? 1,
        szin_id: i.szin_id ?? null
      }))
    }

    try {
      const res = await axios.post('/api/rendeles', apiPayload)
      console.log('Order submitted:', res.data);
      // clear persisted payload on success
      try { sessionStorage.removeItem('orderPayload') } catch(e){}
      overlayMessage.value = 'Rendelés sikeresen elküldve!';
      showOverlay.value = true;
      router.push('/');
      return res;
    } catch (error) {
      console.error('Error submitting order:', error)
      // Handle validation errors (422)
      if (error.response && error.response.status === 422) {
        const data = error.response.data;
        let msg = data.message || 'Érvénytelen adatok';
        if (data.errors) {
          const errs = Object.values(data.errors).flat().join('\n');
          msg = errs || msg;
        }
        overlayMessage.value = msg;
        showOverlay.value = true;
        return;
      }

      overlayMessage.value = 'Hiba a rendelés elküldése közben.';
      showOverlay.value = true;
      return;
    }
}

</script>

<style scoped lang="scss">
@import url("https://fonts.googleapis.com/css?family=Source+Code+Pro:400,500,600,700|Source+Sans+Pro:400,600,700&display=swap");

.wrapper {
  min-height: 100vh;
  display: flex;
  padding: 50px 15px;
  @media screen and (max-width: 700px), (max-height: 500px) {
    flex-wrap: wrap;
    flex-direction: column;
  }
}

.card-form {
  max-width: 570px;
  margin: auto;
  width: 100%;

  @media screen and (max-width: 576px) {
    margin: 0 auto;
  }

  &__inner {
    background: #fff;
    // box-shadow: 3px 13px 30px 0px rgba(21, 34, 67, 0.2);
    box-shadow: 0 30px 60px 0 rgba(90, 116, 148, 0.4);
    border-radius: 10px;
    padding: 35px;
    padding-top: 180px;

    @media screen and (max-width: 480px) {
      padding: 25px;
      padding-top: 165px;
    }
    @media screen and (max-width: 360px) {
      padding: 15px;
      padding-top: 165px;
    }
  }

  &__row {
    display: flex;
    align-items: flex-start;
    @media screen and (max-width: 480px) {
      flex-wrap: wrap;
    }
  }

  &__col {
    flex: auto;
    margin-right: 35px;

    &:last-child {
      margin-right: 0;
    }

    @media screen and (max-width: 480px) {
      margin-right: 0;
      flex: unset;
      width: 100%;
      margin-bottom: 20px;

      &:last-child {
        margin-bottom: 0;
      }
    }

    &.-cvv {
      max-width: 150px;
      @media screen and (max-width: 480px) {
        max-width: initial;
      }
    }
  }

  &__group {
    display: flex;
    align-items: flex-start;
    flex-wrap: wrap;

    .card-input__input {
      flex: 1;
      margin-right: 15px;

      &:last-child {
        margin-right: 0;
      }
    }
  }

  &__button {
    width: 100%;
    height: 55px;
    background: #2364d2;
    border: none;
    border-radius: 5px;
    font-size: 22px;
    font-weight: 500;
    font-family: "Source Sans Pro", sans-serif;
    box-shadow: 3px 10px 20px 0px rgba(35, 100, 210, 0.3);
    color: #fff;
    margin-top: 20px;
    cursor: pointer;

    @media screen and (max-width: 480px) {
      margin-top: 10px;
    }
  }
}

.card-item {
  max-width: 430px;
  height: 270px;
  margin-left: auto;
  margin-right: auto;
  position: relative;
  z-index: 2;
  width: 100%;

  @media screen and (max-width: 480px) {
    max-width: 310px;
    height: 220px;
    width: 90%;
  }

  @media screen and (max-width: 360px) {
    height: 180px;
  }

  &.-active {
    .card-item__side {
      &.-front {
        transform: perspective(1000px) rotateY(180deg) rotateX(0deg)
          rotateZ(0deg);
      }
      &.-back {
        transform: perspective(1000px) rotateY(0) rotateX(0deg) rotateZ(0deg);
        // box-shadow: 0 20px 50px 0 rgba(81, 88, 206, 0.65);
      }
    }
  }

  &__focus {
    position: absolute;
    z-index: 3;
    border-radius: 5px;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    transition: all 0.35s cubic-bezier(0.71, 0.03, 0.56, 0.85);
    opacity: 0;
    pointer-events: none;
    overflow: hidden;
    border: 2px solid rgba(255, 255, 255, 0.65);

    &:after {
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      background: rgb(8, 20, 47);
      height: 100%;
      border-radius: 5px;
      filter: blur(25px);
      opacity: 0.5;
    }

    &.-active {
      opacity: 1;
    }
  }

  &__side {
    border-radius: 15px;
    overflow: hidden;
    // box-shadow: 3px 13px 30px 0px rgba(11, 19, 41, 0.5);
    box-shadow: 0 20px 60px 0 rgba(14, 42, 90, 0.55);
    transform: perspective(2000px) rotateY(0deg) rotateX(0deg) rotate(0deg);
    transform-style: preserve-3d;
    transition: all 0.8s cubic-bezier(0.71, 0.03, 0.56, 0.85);
    backface-visibility: hidden;
    height: 100%;

    &.-back {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      transform: perspective(2000px) rotateY(-180deg) rotateX(0deg) rotate(0deg);
      z-index: 2;
      padding: 0;
      // background-color: #2364d2;
      // background-image: linear-gradient(
      //   43deg,
      //   #4158d0 0%,
      //   #8555c7 46%,
      //   #2364d2 100%
      // );
      height: 100%;

      .card-item__cover {
        transform: rotateY(-180deg)
      }
    }
  }
  &__bg {
    max-width: 100%;
    display: block;
    max-height: 100%;
    height: 100%;
    width: 100%;
    object-fit: cover;
  }
  &__cover {
    height: 100%;
    background-color: #1c1d27;
    position: absolute;
    height: 100%;
    background-color: #1c1d27;
    left: 0;
    top: 0;
    width: 100%;
    border-radius: 15px;
    overflow: hidden;
    &:after {
      content: "";
      position: absolute;
      left: 0;
      top: 0;
      width: 100%;
      height: 100%;
      background: rgba(6, 2, 29, 0.45);
    }
  }

  &__top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 40px;
    padding: 0 10px;

    @media screen and (max-width: 480px) {
      margin-bottom: 25px;
    }
    @media screen and (max-width: 360px) {
      margin-bottom: 15px;
    }
  }

  &__chip {
    width: 60px;
    @media screen and (max-width: 480px) {
      width: 50px;
    }
    @media screen and (max-width: 360px) {
      width: 40px;
    }
  }

  &__type {
    height: 45px;
    position: relative;
    display: flex;
    justify-content: flex-end;
    max-width: 100px;
    margin-left: auto;
    width: 100%;

    @media screen and (max-width: 480px) {
      height: 40px;
      max-width: 90px;
    }
    @media screen and (max-width: 360px) {
      height: 30px;
    }
  }

  &__typeImg {
    max-width: 100%;
    object-fit: contain;
    max-height: 100%;
    object-position: top right;
  }

  &__info {
    color: #fff;
    width: 100%;
    max-width: calc(100% - 85px);
    padding: 10px 15px;
    font-weight: 500;
    display: block;

    cursor: pointer;

    @media screen and (max-width: 480px) {
      padding: 10px;
    }
  }

  &__holder {
    opacity: 0.7;
    font-size: 13px;
    margin-bottom: 6px;
    @media screen and (max-width: 480px) {
      font-size: 12px;
      margin-bottom: 5px;
    }
  }

  &__wrapper {
    font-family: "Source Code Pro", monospace;
    padding: 25px 15px;
    position: relative;
    z-index: 4;
    height: 100%;
    text-shadow: 7px 6px 10px rgba(14, 42, 90, 0.8);
    user-select: none;
    @media screen and (max-width: 480px) {
      padding: 20px 10px;
    }
  }

  &__name {
    font-size: 18px;
    line-height: 1;
    white-space: nowrap;
    max-width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
    text-transform: uppercase;
    @media screen and (max-width: 480px) {
      font-size: 16px;
    }
  }
  &__nameItem {
    display: inline-block;
    min-width: 8px;
    position: relative;
  }

  &__number {
    font-weight: 500;
    line-height: 1;
    color: #fff;
    font-size: 27px;
    margin-bottom: 35px;
    display: inline-block;
    padding: 10px 15px;
    cursor: pointer;

    @media screen and (max-width: 480px) {
      font-size: 21px;
      margin-bottom: 15px;
      padding: 10px 10px;
    }

    @media screen and (max-width: 360px) {
      font-size: 19px;
      margin-bottom: 10px;
      padding: 10px 10px;
    }
  }

  &__numberItem {
    width: 16px;
    display: inline-block;
    &.-active {
      width: 30px;
    }

    @media screen and (max-width: 480px) {
      width: 13px;

      &.-active {
        width: 16px;
      }
    }

    @media screen and (max-width: 360px) {
      width: 12px;

      &.-active {
        width: 8px;
      }
    }
  }

  &__content {
    color: #fff;
    display: flex;
    align-items: flex-start;
  }

  &__date {
    flex-wrap: wrap;
    font-size: 18px;
    margin-left: auto;
    padding: 10px;
    display: inline-flex;
    width: 80px;
    white-space: nowrap;
    flex-shrink: 0;
    cursor: pointer;

    @media screen and (max-width: 480px) {
      font-size: 16px;
    }
  }

  &__dateItem {
    position: relative;
    span {
      width: 22px;
      display: inline-block;
    }
  }

  &__dateTitle {
    opacity: 0.7;
    font-size: 13px;
    padding-bottom: 6px;
    width: 100%;

    @media screen and (max-width: 480px) {
      font-size: 12px;
      padding-bottom: 5px;
    }
  }
  &__band {
    background: rgba(0, 0, 19, 0.8);
    width: 100%;
    height: 50px;
    margin-top: 30px;
    position: relative;
    z-index: 2;
    @media screen and (max-width: 480px) {
      margin-top: 20px;
    }
    @media screen and (max-width: 360px) {
      height: 40px;
      margin-top: 10px;
    }
  }

  &__cvv {
    text-align: right;
    position: relative;
    z-index: 2;
    padding: 15px;
    .card-item__type {
      opacity: 0.7;
    }

    @media screen and (max-width: 360px) {
      padding: 10px 15px;
    }
  }
  &__cvvTitle {
    padding-right: 10px;
    font-size: 15px;
    font-weight: 500;
    color: #fff;
    margin-bottom: 5px;
  }
  &__cvvBand {
    height: 45px;
    background: #fff;
    margin-bottom: 30px;
    text-align: right;
    display: flex;
    align-items: center;
    justify-content: flex-end;
    padding-right: 10px;
    color: #1a3b5d;
    font-size: 18px;
    border-radius: 4px;
    box-shadow: 0px 10px 20px -7px rgba(32, 56, 117, 0.35);

    @media screen and (max-width: 480px) {
      height: 40px;
      margin-bottom: 20px;
    }

    @media screen and (max-width: 360px) {
      margin-bottom: 15px;
    }
  }
}

.card-list {
  margin-bottom: -130px;

  @media screen and (max-width: 480px) {
    margin-bottom: -120px;
  }
}

.card-input {
  margin-bottom: 20px;
  &__label {
    font-size: 14px;
    margin-bottom: 5px;
    font-weight: 500;
    color: #1a3b5d;
    width: 100%;
    display: block;
    user-select: none;
  }
  &__input {
    width: 100%;
    height: 50px;
    border-radius: 5px;
    box-shadow: none;
    border: 1px solid #ced6e0;
    transition: all 0.3s ease-in-out;
    font-size: 18px;
    padding: 5px 15px;
    background: none;
    color: #1a3b5d;
    font-family: "Source Sans Pro", sans-serif;

    &:hover,
    &:focus {
      border-color: #3d9cff;
    }

    &:focus {
      box-shadow: 0px 10px 20px -13px rgba(32, 56, 117, 0.35);
    }
    &.-select {
      
      background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAeCAYAAABuUU38AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAUxJREFUeNrM1sEJwkAQBdCsngXPHsQO9O5FS7AAMVYgdqAd2IGCDWgFnryLFQiCZ8EGnJUNimiyM/tnk4HNEAg/8y6ZmMRVqz9eUJvRaSbvutCZ347bXVJy/ZnvTmdJ862Me+hAbZCTs6GHpyUi1tTSvPnqTpoWZPUa7W7ncT3vK4h4zVejy8QzM3WhVUO8ykI6jOxoGA4ig3BLHcNFSCGqGAkig2yqgpEiMsjSfY9LxYQg7L6r0X6wS29YJiYQYecemY+wHrXD1+bklGhpAhBDeu/JfIVGxaAQ9sb8CI+CQSJ+QmJg0Ii/EE2MBiIXooHRQhRCkBhNhBcEhLkwf05ZCG8ICCOpk0MULmvDSY2M8UawIRExLIQIEgHDRoghihgRIgiigBEjgiFATBACAgFgghEwSAAGgoBCBBgYAg5hYKAIFYgHBo6w9RRgAFfy160QuV8NAAAAAElFTkSuQmCC');
      background-size: 12px;
      background-position: 90% center;
      background-repeat: no-repeat;
      padding-right: 30px;
    }
  }
}

.slide-fade-up-enter-active {
  transition: all 0.25s ease-in-out;
  transition-delay: 0.1s;
  position: relative;
}
.slide-fade-up-leave-active {
  transition: all 0.25s ease-in-out;
  position: absolute;
}
.slide-fade-up-enter {
  opacity: 0;
  transform: translateY(15px);
  pointer-events: none;
}
.slide-fade-up-leave-to {
  opacity: 0;
  transform: translateY(-15px);
  pointer-events: none;
}

.slide-fade-right-enter-active {
  transition: all 0.25s ease-in-out;
  transition-delay: 0.1s;
  position: relative;
}
.slide-fade-right-leave-active {
  transition: all 0.25s ease-in-out;
  position: absolute;
}
.slide-fade-right-enter {
  opacity: 0;
  transform: translateX(10px) rotate(45deg);
  pointer-events: none;
}
.slide-fade-right-leave-to {
  opacity: 0;
  transform: translateX(-10px) rotate(45deg);
  pointer-events: none;
}



.github-btn {
  position: absolute;
  right: 40px;
  bottom: 50px;
  text-decoration: none;
  padding: 15px 25px;
  border-radius: 4px;
  box-shadow: 0px 4px 30px -6px rgba(36, 52, 70, 0.65);
  background: #24292e;
  color: #fff;
  font-weight: bold;
  letter-spacing: 1px;
  font-size: 16px;
  text-align: center;
  transition: all .3s ease-in-out;

  @media screen and (min-width: 500px) {
    &:hover {
      transform: scale(1.1);
      box-shadow: 0px 17px 20px -6px rgba(36, 52, 70, 0.36);
    }
  }

  @media screen and (max-width: 700px) {
    position: relative;
    bottom: auto;
    right: auto;
    margin-top: 20px;

    &:active {
      transform: scale(1.1);
      box-shadow: 0px 17px 20px -6px rgba(36, 52, 70, 0.36);
    }
  }
}

.overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.overlay-content {
  background: white;
  padding: 20px;
  border-radius: 8px;
  text-align: center;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.3);
}

.overlay-content p {
  font-size: 18px;
  margin-bottom: 20px;
}

.overlay-button {
  background: #2364d2;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
}

.overlay-button:hover {
  background: #1a4bb8;
}
#total {
  font-size: 20px;
  font-weight: bold;
  color: #1a3b5d;
}
</style>
