<template>
  <div v-loading="loading">
    <div style="display: flex; width: 100%; height: 90vh">
      <div
        style="width: 50%; height: 90%; border: 1px solid black; margin: 20px"
      >
        <div
          style="
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100%;
            width: 100%;
          "
        >
          <div style="width: 100%;">
            <el-upload
              ref="upload"
              class="upload-demo"
              drag
              :action="action"
              multiple
              :data="datas"
              :auto-upload="false"
              :file-list="fileList"
              :on-change="handleFileChange"
              :show-file-list	='false'
            >
              <i class="el-icon-upload"></i>
              <div class="el-upload__text" style="text-align: center">
                Drag files here, or <em>Click to upload</em>
              </div>
              <!-- <div class="el-upload__tip" slot="tip" style="text-align: center">
                Only jpg/png files can be uploaded, and it should not exceed
                500kb
              </div> -->
            </el-upload>
            <el-image
              v-if="show"
              style="
                width: 100%;
                height: 50vh;
                display: flex;
                justify-content: center;
                align-items: center;
                margin-top: 20px;
              "
              :src="'data:image/png;base64,' + datas.imageBase64"
              fit="scale-down"
            ></el-image>
          </div>
        </div>
      </div>

      <div
        v-if="show1"
        style="width: 50%; height: 90%; border: 1px solid black; margin: 20px"
      >
        <div style="text-align: center">
          Similarity:{{ image[index].similarity }}%
        </div>
        <div>
          <el-image
            style="
              width: 100%;
              height: 70vh;
              display: flex;
              justify-content: center;
              align-items: center;
              margin-top: 20px;
            "
            :src="'data:image/png;base64,' + image[index].image"
            fit="contain"
          ></el-image>
        </div>
      </div>
    </div>
    <div style="display: flex">
      <div style="width: 50%; display: flex; justify-content: space-around">
        <el-button type="primary" round @click="upload">upload</el-button>
        <el-button type="primary" round @click="query">query</el-button>
      </div>
      <div
        v-if="show1"
        style="display: flex; width: 50%; justify-content: space-around"
      >
        <el-button type="primary" round @click="lastpage">last page</el-button>
        <el-button type="primary" round @click="nextpage">next page</el-button>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
export default {
  data() {
    return {
      imageBase64: "",
      action: `${this.$url}/api/VectorSearch/Import`,
      imageName: "",
      fileList: [],
      datas: {
        imageName: "PKQ.png",
        imageBase64:
          "/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAoHCBUSFBgUEhQUGRgaGRgaGBkYGxkcGhoYGhgbGxkYGRobIS0kGyEqJBobJTclLC8zNDQ0GiQ6PzozPi0zNDEBCwsLEA8QHxISHTMqJCozMzw8NTM2MzMxNDozMzM8NDw6PDMzMzMzPDUzMzMzMzMzMzM1PDM8MzMzMzMzMzMzM//AABEIAOAA4AMBIgACEQEDEQH/xAAcAAEAAQUBAQAAAAAAAAAAAAAABQECAwQGBwj/xABDEAACAQIEAwQIAwYDBwUAAAABAgADEQQSITEFQVEGYXGBEyIyQlJikaFygpIHIzOiscFDstEUFSRTY3PhNIOTo7P/xAAaAQEAAgMBAAAAAAAAAAAAAAAAAwQBAgUG/8QAKxEAAgIBAwQCAQMFAQAAAAAAAAECAxEEEiEFMUFRE2EyIpGxFIGhwfBx/9oADAMBAAIRAxEAPwD2aIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIlLwDAKxEQBERAEREAREQBERAEREAREQBERAEREAREQBERAEpE0uIcQSgoZzqTZVGrM3wqvM/0mraSywbk5jtJ24weAutSpnqD/AAqfrPfo3JPMiY8RiquI9smmnKmjesR/1HH+VdO9p4X2r4euGxlanTUKgbMoGwVgGsO4XtK1Wsrtm4RecErqcVlnWcY/a3i6lxh6dOguup/ePbxNlB8p6T+zpK/+xJUxVR3qVSal3NyqNYIoGwFgDYdZ4t2E7NniOKWmf4aWesfkB0TxY6eAM+kUQAAAAACwA2A6S0jRmSIiZNRERAEREA8U7a9o+J8NxjIuJZqbXqUg6IRlJ9jYE5Tp9Jbw79sGJSwxGHpVBzKMabfQhh/Seg/tA7LDiOGyrYVqd2osetvWQno1h5gHlPnR0KkqylWUkMp0KsDZlI5EEWmDdYZ9H8E7ZYfFUlqkVKStcA1VstwbH1wSu/UzpFYEXGoPSefdjVAwOGA/5Y+97yTo0DS1w7mmeagXQnvpk28xY98466tFWyhNYSfcmeneMpnYXlZA4Xjw0XEqKbbB73pse5zbKT0a3cTJ286tdsLFmLyV3Fp4ZdERJDAiIgCIiAIiUgCUiQ3GOJlD6GjY1WFyTqtNTpnYcybHKvOx5AyOyyMIuUnhIyk28Iu4nxUUj6OmA9Ui+W9lRTszkbDQ2G5sbczIdKRzGo7F3IszkWNvhUe4vcPO8rQohAQLkklmZjdmY7sx5n/QTJPLa3qE7ntjwi/VSo8vuJ4/+0DDtU4iadNS7utMKq7sxGgE9fdwoLMQFAJJOgAG5JlvZzs+v+0PxCopzuFWkrCxp0wLZiDszb9wsN7yfo0G7XLxg11DSRs9huzK8NwwpaGo1mquOb22HyrsJ00RPTFEREQBERAEREAoZ5l+03sKcTfF4Rf3oH7ymB/FA2ZfnA/UPCemwYCPM+wVcVMBRt7oZP0sROhmxxHhLU2arhlBzEmpSFhmbnUQ7B9NQdG7jvp4eutQZkN9bHQggjdWB1UjodZ5HqGlnXY5Y4b4OhVYnHBeRcEEXB3B2Pcestwtaphv4PrIN6LG1h/029w/KfV/DL4lWjUTplmDJJwUlhk9gOIU66lkOxsykWZW6Mu4M3Jx70jmFSm2SoBYNa4I+Coumde7ca2Ik3w3iq1QweyVEF3UnQDX11Y2zIbH1tO+xnqNHr4XrHZ+ihZU4/8AhLSl5AVu0GbTDU8/zsSlPxXQs/kLd80qtSs/t13/AA0wEXytdv5ptd1CirhvL+hCmUvB1Za2p0mBsfSG9WmPFl/1nJ/7upE3amrnq93P1cmZFwlMbU6Y8EX/AElGXW4J8RZKtK/Z1dLEI3sureBB/pMs4x+HUW9qlTP5Fv8AW0vpUWp/wqlRO7MWX9L3AHhabV9Zrb/UmjD00vDJ7jHEfQqAgDVHuEU7XG7N8q7nyG5Eg8PRyA6lmY5nc7ux3Y9NtuQAHKWU/SM7vWKs5CqrICFyDkFJJQ31Opvp0mec7qWu+aW2L4X+SamrasvuJbVqKilnICgXJJsABuTMWKxS01u56AAakk6AADUk9BqZt8M4O9Vlq4kWCkFKO9iNnqH3jtZdha+p2g0einfL0vZvZaorJThWAbEFatVStIEGnTYWLkaipUB2A91fM8gOotET1lNMaoqMUc+UnJ5ZWIiTGpSUgyJxXHaSEomao43WnY2PRmJyqe4m80nOMVmTwZSb4RLSsgMFxtjUC16aoG0RlcsL/A5KrlY7i1wdRuBeeBmK7IzWYvKEouLwy6IiSGBERAKSJ4jwdapNRDkqWtnABzAbK67OPuLmxElpSaThGaxJZRlNrlHH16zUCFxKhOjg3pNy9o+wT0byvM06d0BFiAQdCDtbpaQuI7NpqcO7UT0XVP8A4zoB+G04up6Om91Tx9MtV6nxI0pr4jBpUZWqKGyXsDtra9+uw0208JjelXSsKVQoQFzs6ZhcElVUqfZuQTufZm5OJbXPTy2vh/X2WVJTWRERIDYREQZERFpkwJqVqlU1FpU0Ulwcrs1lGX2g3O/MAb67WM25r47MEzpq9OzoOrJrl8xdfzSbTOKsW9ZWTWedrwTXCuBrROd29JV+Nha19wi65B5k9SZMTHRqh1Vl1DAEHqCLiZJ7WEIxWIrg5jbbyyspK3kTjeM06bFFu7jdEsSt9s7HRfMxOcYrMnhBJvsSshsZx2mpKUgari4IU+qp6O+y+Gp7pF13q1/4z5VP+HTJC26M+jP9hrtLkQKAqgAAWAAsAO4DacfU9XjH9NSz9+CzDTN8yLcQalb+PUup/wANLqlujH2n87DulyIFAVQABsAAAPACVicG7U2WvMnktRhGPZFtakrqUcXBFiP9CNj3yS4Fji2alUN6iAHMffpm4V+l9LNbmO8SPmKsrArUp2zoSUvoGv7SE8gwAHcQDylvp2sdM8Ps+5HdXuX2dhKzUwOLWsi1FvlYX10I6hhyINwR1E2561HPEREyBERAEoZWUMA5Ou2avXb51TyRFt93b6wzhQSxAAFySbADqSdpQ/xa/wD3T90pmeW/tT4nUaqMMCQiKGK8mdti3W1tPGeWlp3qdXKOcc/wX4z2VpnpWF4lRqkrSq03YbhHVj9AZtTjO03anhzcNRcJlWsoT0KouV6LLa7E20trf4vOdJwPHHEYelWYWLorN4nf7gzTX6D+nSlF5TM1W7u6N+Igic0nKiQfBcFR4xQq1qlaoqB3RFpuUFNV0DtY+sx9r1tACBbcmcE8S7S9n62BqOo9J6FycrJmyMt7hXy6XF7WP952Oj/Hvlu7+P8AZX1G7HBIdjO01WhiFo1KjVKTvkBYk2JbKjoTc2Jtp0M9cB1njvYjs5UxFdKrIy0kdXLMCA5U3VVv7WoFzPYpr1b4/lWzv5wKd23klOzR/wCGRfgzU/0MVH2Amxj+JU6Fs7am+VRqzW3yqNT47Cc3hsfVQ1KFMBfWz+kbWyPyRPebMr6mwGm+0vo4cIS2rO3tOxu7W2zN0HIbC+gnQs6pCuuOOW0iGNDcnnsZsTjK1f2iaSckRvXb8bj2fwr+ozHRpLTXKihVHICw13PjL4vODqNVZc8yf9vBahXGPYRESsSCIiAIiIMF/Cq/oa2Un93VOnRKo6dzj+ZfmnUTkMRRFRChJF9iN1I1Vh0IIBHhJ3g2ONakC9g6ko4GwddyO4ghh3ET1HStV8kNj7r+CjfXh7l5JOIidcriIiAJQxKQDlKwtXr/AI1P/wBdOcb277JvjCtbDlc6rlZDpnUG6kNsCLnTnfladBxTjFOjVrXBdmqGyrbQKipdidFF1P0M1MN2mUtapTKD484dR+LQEDvnmLfmr1MrK15/c6cKZSrXHB5xw7sLjKrhXT0S+87FTYc7KpNz3T1/B4ZaVNKaCyooVR3AW+szTT4r6T0TtSYh1VmTYgkC9iDvK2o1dmpkoSwkYhWo9jckRw3G4OmDSo1aYsxJBe5LHfVjr9Z51ju0OKxS5GqEqRqqAKCD8Vtx46TRGBY75fAn+0u1dMe1qUv2LCrbPZKuKRBdnTXbUXPcAN5mBnlPZTBFcZROUCzE3FuSNPVpQ1mnjp5JJ5NJLDwaPF+JDDoGtmZjZFva5tcknkBznMvxnEE39JbuVVC/Qgn7ze7Wqc9Jvdyuvg10b7gH9JkDLOnrioKWMtl7S0QlHMuToeHcX9JUT0gAcAoSNFdG1BtyKsBp88mMdW9UIjAO5yqQRcD33H4Rc+NpxWFoVKlRFpAFgwY30VVG7NblytzP27fBYJadz7Tm2ZyBdrbD5V+WR6mMINS8+indBRm1HsajcGAXKrkBWDUltdadmDeyCM5uDqTsdO/JTrslQpULsrEZHIQD2CWHqkEDQ8vOSEjeNqGVFIFy4seagAsxU8jYWv8ANK0LHY9svP8Agi247Eh6VfiH1lQ46j6iQ5lZj4V7JNpMAjqIkNaVHdHwfY2kxEg2xiq2X0nrfCCS/wClbmbuHoYl/YpVPFyEH83rfyySOhtn+KyaSlGPdm/K4Gt6Kure7VtTfuYXNNu7cqet16S+hwTEtrUrU0Hwohdv1uQP5ZvUuAUwVZ2qOVIIztpcEEHKtl0IHLlOlounXVWKbaRWttjKOETURE9CUxERAEtMulIB43xajkxNcHf0zsevrHMPsVmpO+7Z9nmq/wDEUFu4FnQbuo2I+ZenMachONwfDKtYAouVWFw72ygdbA3a3TTppOPqobJOUu3s9HpNXW6Um8NeDpOzdQth0v7pZB+FWIX6DSSkw4PDLSprTS9lFrnc9Se8nWZp5y2Sc3JdslNnnOO4MaVZ6dNbLfOp2GRySNe7Uflly8Ibm4HkTOz4xgTUUOg9dL5R8Sn2kv5AjvHjIJGDC4v0N9wRuCOR6iei0eo+WC9ruWqbFjHoxdneHFMSpJBsjtttso/zTs5DdnqOj1eT2VPwLc5h3Ek+QEmZx+oWqdrx44K9kt0mzBjMIlVCji4PkQeTA8iJy+M4DURlVKiOXJChgytYWzMwFxZQRc6chznWV6qopdzZVBJ/8Dme6YcHSbWo4s72uN8iD2Uv3XN+pJ7pHTbKEc+PX2YjZKP4vBbw7AJQTImpOrsd3bqf7DkJtxErzk5PLMCQ+KfPWPRFyD8b2Z/oAg+skcbiRSptUIJyi4Ubs2yoO8kgec2ODdnKLUld3etnGcnMQhLes1lW1xcne86PT9I7stcYIbbFDGSBfEIpylhmOyjVj4KNftNqhgq7+xQqeL2Qfzet9p2mEwNOiMtKmiDoqgfW282Z2YdNgvyeSCWqk+xyVDszWbWpVRB8KKXb9b2H8skqXZigPbD1P+4xI/SLL9pNiVluGmqj2iiGVs5d2YMNhUpjLTRFHRFCj7TPaViWCMpaJWIAiIgCIiAIiIBaZA8U4TYtVoFVbVnVtEqW3JPuN8w8wdLT0h+0tT9z6P8A5rLT/K2rfyhpBqIwdb3rKwbQb3LBB4DHpVAy5lYqGyOLOFYXBtzHeNJtTHiMOj2zrexup2KnqpGo8peikCxYt3m1/O08XPY+Y/sdNZ8lZrYjh1Koc1SmjHmSNx0PXzmyfrNZ8YBoVN++0xDenmLwbYybIiaYxLubKAPvNxBYb375iSa7jBqVVz1FBHqJZz8z+4PyjXxZek24iJSzhGEhETVx1RwMlFS9RgSqgA2C+05BPK+3MkCZrqlOSjHuxJpLLNHG1fSVMo9imdfmqEaDwUfdvlkj2dx3oanonP7uoxKH4Kh1K+D7jowPUSIwoUIMhuvU3uTfUtfXNe9763vL6tMOpU7HpoQeRB5EHUHrOrp7nRNelwazrU4YPRbyshuz3EzXQq5HpUsr20ve+VwOQYAnxBHKTM9LGSksrscxpp4ZWIibGBERAEREAREQBERAEREApOd7QPevRXkqVXI77oqn+Zp0QnNcW/8AVHuop96j3/yiUeoy26eT+iSlZmjDDXtpa/K+1++InjzpGPD1RUUMNL7g7gjQg94NxL3QNuLzVw/q1KicjlqL+a6v9CoP55tzaa2vgRfBREC7ACViJqZERKOtxa5HeIBo8V4mmHQsQWaxsi+0bC5+nM8pfhuJrQDehy16z29JVvaktr5UVt2Vbmyr3kkEzXXhd2ObXMMrN8p5Ach3TUwJPo0B3AynxX1SB5idTS2xpg3BZl7I5V73z2MlmLu7tmdyCxACrcC2ijb7nqTL5bQLVDlpI1QjQ5BdQejOfVHheTGE7NVX1rOEHwU9W/NUYfYL5yaGluve5rv5ZmVsILBDDH/7M6VhqwupQatUQ2zIijV2FrgdRbS5noim80sBwqlQ1poAx3Y6sfFjqZvTt6al1Q2t5OfbNSllIuiIlkjEREAREQBERAEREAREpeAJzXGRbFL81E2/JUF//wBJ0l5y3H8dTarSyNmZHam+UEqudbZWYaBsyppe8pa9ZokvokqeJopERPGnSNTEaVaTdc6fqUOPuk25rY4ewelRPuCv95sySf4r/vJhd2IiJGbCIJtqeW8j6nG8Op1qrbm+pQa21ceqNSBvzHWbRrnL8Vkw2l3JCQOJcUqlQEgDMHF9B645nl6ytr3ydRwwBUgg7EG4PgRvOd7X0kCCqxqA5Hpgpr6zWZA4JAKXVgb/ABaayzo45s2PjJhyxybHZrtNTpVhRY2p1DpfQU6pNiPBj5Xsfe09Enzuy3FiAbjUf1E9W/Z7x58TTalUDFqWUCpYlXU3AUt8a21G9rHmZ6rTv9O1+Ctq6dv6kdpKxEtFMREQBERAEREAREQBERAKTlO2ldx6BA5RHdg7AkEHLZNQQdGYN+WdXOd7aYUVMMWbZGVj3Kbox8gxPlIrU3F49G0fyRC4Pitb0VOiWfLVAtVLeullJqUix1zXHqtvbNzUX2auEU0/RpZAFsmUWCEaqQO4gHykZSpWVkZj6xuSPdffOo65vWkngsQXS7ABwSrgbBxvbuOhHcwnl9XfOeOeEdCFajx7LsHiPSIGtY7MvwuDZ18jeZpoVanoqhNnIdMwVVJvUUhSBbYlSN9PVv1j/egN8iVHsNcq7PyQ31DddLDS9udOVTbzFcM33Y7mXHn+Hfb0iXP1t97Dzm1NBaD1GzVRkAyZUV8wLK2YsSAL65QNvZM35ixJJR9BCY8RWFNcxueQA3YnYDvmSUKC4PMXt3XkccZ5MsjcVSOQ1KwV3uAlLemHY2RbH2zci7HvsBNN8MFOU+sBoSfeFNXqVH86jp9JvY6t+9RR7ilz+JvUT7Zz9Jq4hyKb29pkZB+J9B9zL9c2kvs0cM8m7w/ChFRk9UlEzgaKxyDUjk3fz53mLtNQz4WqPhXOPFPW/tJMLbQbDQeW0x4lMyOp5o4+qkStGx/Km/ZtjCIPs9+z5ms+MbKvKkh1P43G34V+s9EwuFSkgSmioiiwVRYDwAmLhT5qFJjuaaH6qJuT2sIpLg5tlkpPLZWIibmgiIgCIiAIiIAiIgCIiAJhr0lqKyMLqwKkdQRYiZpQiAecJTZC1NzdkYox65fZbzWx85s4RstS99GGVvEao39VPl0kn2rwWVhiV2ACVh8t/Ue/ykkHubukORPM62j45teGdOmanH7Jgm28wvilHMnwkZe/OVnPVS8slwbbY7ov1lgxjd014m3xx9GcI3kxo94EeGsufFqBprI+FGsfCsmMGCg5dnc7s5Hkgy2+ub6y3FG7IvVwfJLv/ULKcNN6aN8QLfqJP94T1qrHkihB+J7M/wBgn1ljHL+h4SJ3D1g47+YlnEHK0nKi7ZSFHV29VB5kiR4Ntdu+SPAcK+JqLWa/oUOZCf8AEfky/KN78yRba5102jlbYsdvJHdJRjk6zC0clNEHuqq/pAH9pnlLSs9cjliIiAIiIAiIgCIiAIiIAiIgCIiAYqiBgQQCCLEHYg7gicRxThjYQnQmh7ranIPhfuHJumhta57uJBfRG1Ykb12ODyjz3hvDa9RC9JKbIzuULOUJUt7QGQixN7G+om+vAcUd1oL41Hb+iCdlaLSFaGnyiT+on4ZylPsxVPt4hB3JTN/Jnc/0m5T7K0/fqVn8WC/5AJ0ESWOlqXaKNHbN92QR7LUORqj/ANxz/WadXssw1p4hvCoquPqhQj7zqZS0zLT1vhxQVsl2Z5jhj6JRRNmqITTyL7TupIAVdwCNbnkbmTOE7L4kLZqlBSbszBXqEsTc2BKDnadgKCZs+VcxFi1he3S+9plkENBWm2+cm8tRJ4wQGD7MUlsaxasd7PYJf8C6HzvJ8SsS3CEYrEVghlJvllYiJuYEREAREQBERAEREA//2Q==",
      },
      id: "",
      count: "",
      size: "",
      index: 0,
      image: [],
      show: false,
      loading: false,
      page: 1,
      show1: false,
    };
  },
  methods: {
    upload() {
      this.loading = true;
      axios.post(`${this.$url}/api/VectorSearch/Import`, this.datas).then((res) => {
        if (res.data.code == 200) {
          this.id = res.data.data.id;
          this.loading = false;
          this.$message.success("Upload successful!");
        }
      });
    },
    handleFileChange(file) {
      this.datas.imageName = file.name;
      const reader = new FileReader();
      reader.onloadend = () => {
        //After the reading is completed, the reader.result will contain the Base64 format string of the file
        this.datas.imageBase64 = reader.result.substring(
          reader.result.indexOf(",") + 1,
          reader.result.length
        );
        this.show = true
      };
      if (file.raw) {
        reader.readAsDataURL(file.raw);
      }
    },
    lastpage() {
      this.page -= 1;
      this.query();
      if (this.index > 0) {
        this.index -= 1;
      }
    },
    nextpage() {
      this.page += 1;
      this.query();
      if (this.index < this.image.length - 1) {
        this.index += 1;
      }
    },
    query() {
      axios
        .post(`${this.$url}/api/VectorSearch/SearchImage`, {
          id: this.id,
          count: "11",
          size: "1",
          page: this.page,
        })
        .then((res) => {
          if (res.data.code == 200) {
            this.image = res.data.data.data;
            this.image.forEach((item) => {
              item.similarity = Math.ceil(item.similarity * 100);
            });
            this.show1 = true;
            console.log(this.image[this.index].similarity);
          }
        });
    },
  },
};
</script>
<style scoped>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
page {
  width: calc(100% - 30rpx);
  margin: 0 auto;
}
.upload-demo {
  margin-bottom: 40rpx;
  display: flex;
  justify-content: center;
}

/deep/ .el-upload .el-upload-dragger {
  width: 120%;
  height: 100%;
}
</style>
