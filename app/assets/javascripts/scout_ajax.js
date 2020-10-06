$(document).on('click', '.scout_ajax', function(e){
    e.preventDefault();    
    var id = $(this).attr('id');
    let url = '/scout_ajax';  // action属性のurlを抽出
    $.ajax({
      url: url,  // リクエストを送信するURLを指定
      type: "GET",  // HTTPメソッドを指定（デフォルトはGET）
      data: {  // 送信するデータをハッシュ形式で指定
        id: id
      },
      dataType: "json"  // レスポンスデータをjson形式と指定する
    })
    .done(function(data) {
        console.log(data);
      $("#start_time").val(data.start_time);
      $("#price").val(data.price);
      $('input[name=beer]').val([data.beer]);  
      $("#drink_time").val(data.drink_time);
      $("#content").val(data.content);
      $("#hope").val(data.hope);
    })
    .fail(function() {
      alert("error!");  // 通信に失敗した場合はアラートを表示
    })
    .always(function() {
    //   $(".note_form-btn").prop("disabled", false);  // submitボタンのdisableを解除
    //   $(".note_form-btn").removeAttr("data-disable-with");  // submitボタンのdisableを解除(Rails5.0以降はこちらも必要)
    });

});