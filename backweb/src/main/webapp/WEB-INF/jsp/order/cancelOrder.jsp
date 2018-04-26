<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<jsp:include page="/WEB-INF/jsp/layout/head.jsp" />
<script src="/static/js/module/etbs.order.js"></script>
<script>
$(function() {
	init();

	//로컬스토리지 복원
	var items = sessionStorage.getItem(location.pathname);
	if(items) {
		items = $.parseJSON(items);
		etbs.formWrite({
			element: $('#clmSearchForm'),
			data: items.formStatus
		});

		search();
	}
});

function init() {
	$('#dateSearchType').val('clmAcptDts');
	$('#dateSelect').val('0');
	$('#startDate').val(new Date().format('yyyy-MM-dd'));
	$('#endDate').val(new Date().format("yyyy-MM-dd"));
	$('input[type="checkBox"][name="payWayCd"]').prop("checked", false);
	$('#payWayAll').prop("checked", true);
	$('#patrNo').val('${USR_PATR_NO}');
	$('#patrNm').val('${USR_PATR_NM}');
	$('#vndrNo').val('${USR_VNDR_NO}');
	$('#vndrNm').val('${USR_VNDR_NM}');
	$('#cmpyNo').val('');
	$('#cmpyNm').val('');
	$('#searchOrdrType').val('ordrNm');
	$('#searchOrdrKeyword').val('');
	$('#searchNoType').val('ordNo');
	$('#searchNoKeyword').val('');
	
	//rudolph:170511-메인페이지 링크 이동 대응
	var params = etbs.param.getParams();
	if(params) {
		var startDate = etbs.param.getParam('startDate');
		var endDate = etbs.param.getParam('endDate');
		
		if(startDate) {
			$('#startDate').val(startDate);
		}
		if(endDate) {
			$('#endDate').val(endDate);		
		}
		
		search();
	}
}

function search() {

	var patrNo = $('#patrNo').val();
	var vndrNo = $('#vndrNo').val();

	if(patrNo != '' && vndrNo != '') {
		etbs.alert.open({message: '협력사와 고객사를 같이 검색할 수 없습니다. 둘중 하나만 선택해 주십시오'});
		return;
	}

	clmSheet.DoSearchPaging('/order/getCancelOrder',  {
		Param:'pageCount=' + clmSheet.GetPageCount() + '&' + $('#clmSearchForm').serialize()
	});

}

//취소사유 팝업
function cancelCmsnReason(clmNo, clmProdNo) {
	//test console : cancelCmsnReason('10052', '0')
	$('#popClmNo').val(clmNo);
	$('#popClmProdNo').val(clmProdNo);

	clmRsnBindData();

	etbs.popup({
		target: 'popClaimCmsnRsn',
		width: 600,
		height: 200,
		callback: function(data){
			$('#popClmNo').val('');
			$('#popClmProdNo').val('');
			$('#popOrdNo').html('');
			$('#popProdNo').html('');
			$('table#rsn tr#newRow').remove();
		}
	});
}


function showCompanyPopup(target) {
	etbs.popup({
		target: 'popCompany',// etbs.popup 하위 객체를 생성한다. (필수)
		width: 850,
		height: 650,
		radio : true, 				  //true:단일선택 false:다중선택
		sheetId : 'popCompanySheet', //popup 에 시트를 제어할때
		callback: function(data){
			if(data) {
				var obj = data[0];
				$('#cmpyNo').val(obj.cmpyNo);
				$('#cmpyNm').val(obj.cmpyNm);
			} else {
				$('#cmpyNo').val('');
				$('#cmpyNm').val('');
			}
		}
	});
	popCompanySheet.FitColWidth();
}

function popPartnerOpen(){ //협력사 찾기 팝업
	etbs.popup({
		target :'popPartner',
		width : 750,
		height : 550,
		radio : true, 				  //true:단일선택 false:다중선택
		sheetId : 'popPartnerSheet', //popup 에 시트를 제어할때
		callback : function(data) {
			if(data){
				var obj = data[0];
				$('#patrNo').val(obj.patrNo);
				$('#patrNm').val(obj.patrNm);
			} else {
				$('#patrNo').val('');
				$('#patrNm').val('');
			}
		}
	});
	popPartnerSheet.RemoveAll();
	popPartnerSheet.FitColWidth();
}

function popVendorOpen(){ //제휴사 찾기 팝업
	etbs.popup({
		target :'popVendor',
		width : 750,
		height : 550,
		radio : true, 				//true 단일 선택 false:다중선택
		sheetId : 'popVendorSheet', //popup 에 시트를 제어할때
		callback : function(data){
			if(data){
				var obj = data[0];
				$('#vndrNo').val(obj.vndrNo);
				$('#vndrNm').val(obj.vndrNm);
			} else {
				$('#vndrNo').val('');
				$('#vndrNm').val('');
			}
		}
	});
	popVendorSheet.RemoveAll();
	popVendorSheet.FitColWidth();
}

</script>
</head>
<body>
<jsp:include page="/WEB-INF/jsp/layout/unit.jsp" />
<div id="container">
    <jsp:include page="/WEB-INF/jsp/layout/header.jsp" />
    <jsp:include page="/WEB-INF/jsp/layout/menu.jsp" />
    <div id="wrapper">
	<h3>주문취소 조회</h3>
	<form id="clmSearchForm" name="clmSearchForm">
		<div class="searchWrapper">
			<table>
				<tr>
					<th>기간</th>
					<td colspan="3">
						<select id="dateSearchType" name="dateSearchType">
							<option value="ordAcptDts">주문접수일</option>
							<option value="payFinDts">결제완료일</option>
							<option value="rlsFinDts">출고완료일</option>
							<option value="clmAcptDts" selected="selected">주문취소일</option>
						</select>
						<span class="datePicker" id="dpDate" data-format="yyyy-MM-dd">
							<input type="text" name="startDate" id="startDate" value="" />
							<input type="text" name="endDate" id="endDate" value=""/>
							<button type="button" class="btnDatePicker"></button>
						</span>
						<select class="dateSelect" id="dateSelect" name="dateSelect">
							<option value="0" selected="selected">오늘</option>
							<option value="7">1주일</option>
							<option value="30">1개월</option>
							<option value="90">3개월</option>
						</select>
						<script>
						etbs.datePicker({
							element : $('#dpDate'),
							callback : function(){
								var startDate = etbs.datePicker.dpDate.start.date;
								var endDate = etbs.datePicker.dpDate.end.date;
								var calcDate = startDate;
								calcDate.setMonth(calcDate.getMonth() + 3);
								if(calcDate < endDate) {
									etbs.alert.open({message: '조회 기간은 최대 3개월 조회 가능합니다'})
									$('#endDate').val(calcDate.format("yyyy-MM-dd"));
								}
							}
						});
						</script>
					</td>
				</tr>
				<tr>
					<th>결제수단</th>
					<td colspan="3">
						<input type="checkBox" id="payWayAll" name="payWayCd" value="" checked="checked" /> 전체
						<c:forEach items="${OR014 }" var="i">
						<input type="checkBox" name="payWayCd" id="payWayCd${i.cd }" value="${i.cd}"  style="margin-left:6px;"/> ${i.cdNm}
						</c:forEach>
					</td>
				</tr>
				<tr>
					<th>협력사</th>
					<td>
						<input type="hidden" id="patrNo" name="patrNo" value="${USR_PATR_NO }" />
						<input type="text" id="patrNm" name="patrNm" placeholder="협력사명" value="${USR_PATR_NM}" />
						<c:if test="${SYS_TP_CD == '10'}">
						<script>
						$(function(){
							//협력사명 자동완성
							$( "#clmSearchForm input[name=patrNm]" ).autocomplete({
						        source : function( request, response ) {
						             $.ajax({
						                    type: 'post',
						                    url: "/partner/getPartnerListAutoComplete",
						                    dataType: "json",
						                    //request.term = $("#autocomplete").val()
						                    data: "searchText="+$( "#clmSearchForm input[name=patrNm]" ).val(),
						                    success: function(data) {
						                        //서버에서 json 데이터 response 후 목록에 뿌려주기 위함
						                        response(
						                            $.map(data.Data, function(item) {
						                                return {
						                                    label: "[" + item.patrNo + "] ["+item.patrStatNm+"] " + item.patrNm,
						                                    value: item.patrNm,
						                                    no: item.patrNo
						                                }
						                            })
						                        );
						                    }
						               });
						            },
						        //조회를 위한 최소글자수
						        minLength: 2,
						        select: function( event, ui ) {
						            // 만약 검색리스트에서 선택하였을때 선택한 데이터에 의한 이벤트발생
						        	$("#clmSearchForm input[name=patrNm]").val(ui.item.value);
						        	$("#clmSearchForm input[name=patrNo]").val(ui.item.no);
						        },
						        focus: function ( event, ui ){
					                return false;
					            },
					            open: function(){
					                $('.ui-autocomplete').css('width', '400px');
					            }
						    });
							
							$("#clmSearchForm input[name=patrNm]").bind('keypress keydown keyup', function(e){ /* 자동완성 키 입력 필드 엔터키 이벤트시 cmpyNo가 없으면 엔터키 방지 처리 */ 
							       if(e.keyCode == 13 && $("#clmSearchForm input[name=patrNo]").val() == "" ) { 
							    	   e.preventDefault(); 
							       }
							});

						});
						</script>
						<span class="button"><button type="button" onclick="popPartnerOpen()">찾아보기</button></span>
						</c:if>
					</td>
					<th>제휴사</th>
					<td>
						<input type="hidden" id="vndrNo" name="vndrNo" value="${USR_VNDR_NO }" />
						<input type="text" id="vndrNm" name="vndrNm" placeholder="제휴사명" value="${USR_VNDR_NM }"/>
						<c:if test="${SYS_TP_CD == '10'}">
						<script>
						$(function(){
							//제휴사명 자동완성
							$( "#clmSearchForm input[name=vndrNm]" ).autocomplete({
						        source : function( request, response ) {
						             $.ajax({
						                    type: 'post',
						                    url: "/vendor/getVendorListAutoComplete",
						                    dataType: "json",
						                    //request.term = $("#autocomplete").val()
						                    data: "searchText="+$( "#clmSearchForm input[name=vndrNm]" ).val(),
						                    success: function(data) {
						                        //서버에서 json 데이터 response 후 목록에 뿌려주기 위함
						                        response(
						                            $.map(data.Data, function(item) {
						                                return {
						                                    label: "[" + item.vndrNo + "] ["+item.vndrStatNm+"] ["+item.itwkInfoUseYn+"] [" + item.vndrItwkInfoNo + "] " + item.vndrNm,
						                                    value: item.vndrNm,
						                                    no: item.vndrNo
						                                }
						                            })
						                        );
						                    }
						               });
						            },
						        //조회를 위한 최소글자수
						        minLength: 2,
						        select: function( event, ui ) {
						            // 만약 검색리스트에서 선택하였을때 선택한 데이터에 의한 이벤트발생
						        	$("#clmSearchForm input[name=vndrNm]").val(ui.item.value);
						        	$("#clmSearchForm input[name=vndrNo]").val(ui.item.no);
						        },
						        focus: function ( event, ui ){
					                return false;
					            },
					            open: function(){
					                $('.ui-autocomplete').css('width', '400px');
					            }
						    });
							
							$("#clmSearchForm input[name=vndrNm]").bind('keypress keydown keyup', function(e){ /* 자동완성 키 입력 필드 엔터키 이벤트시 cmpyNo가 없으면 엔터키 방지 처리 */ 
							       if(e.keyCode == 13 && $("#clmSearchForm input[name=vndrNo]").val() == "" ) { 
							    	   e.preventDefault(); 
							       }
							});
							
						});
						</script>
						<span class="button"><button type="button" onclick="popVendorOpen()">찾아보기</button></span>
						</c:if>
					</td>
				</tr>
				
				<c:choose>
				<c:when test="${SYS_TP_CD == '10'}">
						<tr>
							<th>고객사</th>
							<td colspan="3">
								<input type="hidden" id="cmpyNo" name="cmpyNo" />
								<input type="text" id="cmpyNm" name="cmpyNm" placeholder="고객사명" />
								<script>
								$(function(){
									//고객사명 자동완성
									$( "#clmSearchForm input[name=cmpyNm]" ).autocomplete({
								        source : function( request, response ) {
								             $.ajax({
								                    type: 'post',
								                    url: "/company/getCompanyBaseInfoAutoComplete",
								                    dataType: "json",
								                    //request.term = $("#autocomplete").val()
								                    data: "schText="+$( "#clmSearchForm input[name=cmpyNm]" ).val(),
								                    success: function(data) {
								                        //서버에서 json 데이터 response 후 목록에 뿌려주기 위함
								                        response(
								                            $.map(data.resultMap.companyBaseInfoList, function(item) {
								                                return {
								                                    label: "[" + item.cmpyNo + "] [" + item.cmpyStatCdNm + "] [" + item.itrlTpCdNm + "] " + item.cmpyNm,
								                                    value: item.cmpyNm,
								                                    no: item.cmpyNo
								                                }
								                            })
								                        );
								                    }
								               });
								            },
								        //조회를 위한 최소글자수
								        minLength: 2,
								        select: function( event, ui ) {
								            // 만약 검색리스트에서 선택하였을때 선택한 데이터에 의한 이벤트발생
								        	$("#clmSearchForm input[name=cmpyNm]").val(ui.item.value);
								        	$("#clmSearchForm input[name=cmpyNo]").val(ui.item.no);
								        },
								        focus: function ( event, ui ){
							                return false;
							            },
							            open: function(){
							                $('.ui-autocomplete').css('width', '450px');
							            }
								    });
									
									$("#clmSearchForm input[name=cmpyNm]").bind('keypress keydown keyup', function(e){ /* 자동완성 키 입력 필드 엔터키 이벤트시 cmpyNo가 없으면 엔터키 방지 처리 */ 
									       if(e.keyCode == 13 && $("#clmSearchForm input[name=cmpyNo]").val() == "" ) { 
									    	   e.preventDefault(); 
									       }
									});
									
								});
								</script>
								<span class="button"><button type="button" onclick="showCompanyPopup()">찾아보기</button></span>
		
								<select id="searchOrdrType" name="searchOrdrType" style="margin-left:10px;">
									<option value="ordrNm" selected="selected">주문자명</option>
									<option value="empen">사번</option>
									<option value="ordrHpNo">휴대폰번호</option>
								</select>
								<input type="text" id="searchOrdrKeyword" name="searchOrdrKeyword" class="sizeM" />
		
								<select id="searchNoType" name="searchNoType" style="margin-left:10px;">
									<option value="ordNo" selected="selected">주문번호</option>
									<option value="vndrOrdNo">제휴사주문번호</option>
									<option value="refOrdNo">연관주문번호</option>
								</select>
								<input type="text" id="searchNoKeyword" name="searchNoKeyword" class="sizeM" />
							</td>
						</tr>
				</c:when>
				<c:otherwise>
						<tr>
							<td colspan="2">
								<select id="searchOrdrType" name="searchOrdrType" style="margin-left:10px;">
									<option value="ordrNm" selected="selected">주문자명</option>
									<option value="empen">사번</option>
									<option value="ordrHpNo">휴대폰번호</option>
								</select>
								<input type="text" id="searchOrdrKeyword" name="searchOrdrKeyword" class="sizeM" />
		
								<select id="searchNoType" name="searchNoType" style="margin-left:10px;">
									<option value="ordNo" selected="selected">주문번호</option>
									<option value="vndrOrdNo">제휴사주문번호</option>
									<option value="refOrdNo">연관주문번호</option>
								</select>
								<input type="text" id="searchNoKeyword" name="searchNoKeyword" class="sizeM" />
							</td>
						</tr>
				</c:otherwise>
				</c:choose>
				
			</table>
		</div>
		<div class="btnWrap">
			<span class="button on"><button type="button" onclick="search();">조회</button></span>
			<span class="button"><button type="button" onclick="init();">초기화</button></span>
		</div>
		<div class="titleWrap">
			<h4>주문취소상품 목록</h4>
		</div>
		<div class="sheetBtnWrap">
			<div class="btnArea">
				<span class="button ico"><a title="엑셀다운로드" onclick="clmSheet.Down2Excel()"><b class="ico7"></b></a></span>
			</div>
		</div>
		<div id="clmSheet" class="sheetContainer"></div>
		<script>
			// 시트 객체 생성(전역객체의 프로퍼티로 sheet가 생성됨)
			createIBSheet('clmSheet', 'clmSheet', '100%', '500px');
			// 설정 객체
			var initdata = {};
			// SetConfig
			initdata.Cfg = {SearchMode:4, Page:100};
			// InitHeaders의 두번째 인자
			initdata.HeaderMode = {Sort:true, ColMove:true, ColResize:true, HeaderCheck:false};
			// InitColumns + Header Title

			initdata.Cols = [
				{Header:'클레임번호',	SaveName:'clmNo',		Type:'Text',	MinWidth:100,	Edit:false, Hidden:true,	Align:'Center'},
				{Header:'클레임상세번호',	SaveName:'clmProdNo',	Type:'Text',	MinWidth:100,	Edit:false,	Hidden:true, Align:'Center'},
				{Header:'주문취소일시',	SaveName:'clmAcptDts',	Type:'Date',	MinWidth:150,	Edit:false,	Align:'Center', Format: 'yyyy-MM-dd HH:mm:ss'},
				{Header:'주문번호',		SaveName:'ordNo',		Type:'Text',	MinWidth:150,	Edit:false,	Align:'Center', FontUnderline:true},
				{Header:'제휴사주문번호',	SaveName:'vndrOrdNo',	Type:'Text',	MinWidth:100,	Edit:false,	Align:'Center'},
				{Header:'상품번호',		SaveName:'prodNo',		Type:'Text',	MinWidth:100,	Edit:false,	Align:'Center', FontUnderline:true},
				{Header:'상품명',		SaveName:'prodNm',		Type:'Text',	MinWidth:200,	Edit:false,	Align:'Left', FontUnderline:true},
				{Header:'단품명',		SaveName:'proditNm',	Type:'Text',	MinWidth:150,	Edit:false,	Align:'Center'},
				{Header:'상품유형',		SaveName:'prodTpCdNm',	Type:'Text',	MinWidth:100,	Edit:false,	Align:'Center'},
				{Header:'고객사',		SaveName:'cmpyNo',		Type:'Text',	MinWidth:100,	Edit:false,	Hidden:true, Align:'Center'},
				{Header:'고객사명',		SaveName:'cmpyNm',		Type:'Text',	MinWidth:100,	Edit:false,	Align:'Center', FontUnderline:true},
				{Header:'주문자명',		SaveName:'ordrNm',		Type:'Text',	MinWidth:100,	Edit:false,	Align:'Center'},
				{Header:'클레임등록자',		SaveName:'cuserNm',		Type:'Text',	MinWidth:100,	Edit:false,	Align:'Center'},
				{Header:'주문상태',		SaveName:'ordStatCdNm',	Type:'Text',	MinWidth:100,	Edit:false,	Align:'Center'},
				{Header:'현수량',		SaveName:'curOrdQty',	Type:'Int',		MinWidth:70,	Edit:false,	Align:'Right', Format: '#,##0'},
				{Header:'공급가액',		SaveName:'proditSuprc',	Type:'Int',		MinWidth:70,	Edit:false,	Align:'Right', Format: '#,##0'},
				{Header:'판매금액',		SaveName:'proditSeprc',	Type:'Int',		MinWidth:70,	Edit:false,	Align:'Right', Format: '#,##0'},
				{Header:'협력사or제휴사',	SaveName:'sellMnatCd',	Type:'Text',	MinWidth:100,	Edit:false,	Hidden:true, Align:'Center'},
				{Header:'협력사제휴사번호',	SaveName:'relcopNo',	Type:'Text',	MinWidth:100,	Edit:false,	Hidden:true, Align:'Center'},
				{Header:'업체명',		SaveName:'relcopNoNm',	Type:'Text',	MinWidth:100,	Edit:false,	Align:'Center', FontUnderline:true},
				{Header:'담당MD',		SaveName:'userNm',		Type:'Text',	MinWidth:100,	Edit:false,	Align:'Center'},
				{Header:'제휴사',		SaveName:'vndrNo',		Type:'Text',	MinWidth:100,	Edit:false,	Hidden:true, Align:'Center'},
				{Header:'연관주문번호',	SaveName:'refOrdNo',	Type:'Text',	MinWidth:100,	Edit:false,	Align:'Center'},
				{Header:'취소수량',		SaveName:'clmAcptQty',	Type:'Int',		MinWidth:70,	Edit:false,	Align:'Right', Format: '#,##0'},
				{Header:'취소수수료금액',	SaveName:'cnlPayPrc',	Type:'Int',		MinWidth:100,	Edit:false,	Align:'Right', Format: '#,##0', FontUnderline:true},
				{Header:'수수료 발생 사유',	SaveName:'cnlPayReason', Type:'Text',	MinWidth:100,	Edit:false,	Align:'Center', FontUnderline:true},
				{Header:'비고',			SaveName:'clmRsnSstc',	Type:'Text',	MinWidth:100,	Edit:false,	Align:'Left'}
			];
			// 시트 초기화
			initSheet(clmSheet, initdata);
			//건수 정보 표시
			clmSheet.SetCountPosition(4);
			//페이지 네비게이션 버튼 표시
			clmSheet.SetPagingPosition(1);

			function clmSheet_OnClick(row, col, value, cellX, cellY, cellW, cellH){
				if (row != 0) {
					if(clmSheet.ColSaveName(col) == 'cnlPayPrc') {
						if(clmSheet.GetCellValue(row, 'cnlPayPrc') != '0') {
							var clmNo = clmSheet.GetCellValue(row, 'clmNo');
							var clmProdNo = clmSheet.getCellValue(row, 'clmProdNo');
							cancelCmsnReason(clmNo, clmProdNo);
						}
					} else if(clmSheet.ColSaveName(col) == 'ordNo') {
						//주문상담처리
						var ordNo = clmSheet.GetCellValue(row, 'ordNo');
						orderPop.orderCounseling(ordNo, '_new');
					} else if(clmSheet.ColSaveName(col) == 'cmpyNm') {
						//고객사 상세
						var cmpyNo = clmSheet.GetCellValue(row, 'cmpyNo');
						orderPop.cmpyDetail(cmpyNo, '_new');
					} else if(clmSheet.ColSaveName(col) == 'prodNo') {
						//상품상세
						var prodNo = clmSheet.GetCellValue(row, 'prodNo');
						orderPop.prodDetail(prodNo, '_new');
					} else if(clmSheet.ColSaveName(col) == 'prodNm') {
						//FO상품상세
						var prodNo = clmSheet.GetCellValue(row, 'prodNo');
						var cmpyNo = clmSheet.GetCellValue(row, 'cmpyNo');					
						var folinkParam = 'path=/product/product?prodNo=' + prodNo;
						folinkParam += "&cmpyNo=" + cmpyNo;
						$.post('/company/getUrlByCompany', folinkParam, function(data) {
							if(data.success) {
								var url = data.url;
								orderPop.foProdDetail(url, '_new');							
							}
						});
						
					} else if(clmSheet.ColSaveName(col) == 'relcopNoNm') {
						//협력사or제휴사
						var relcopNo = clmSheet.GetCellValue(row, 'relcopNo');
						var sellMnatCd = clmSheet.GetCellValue(row, 'sellMnatCd');
						orderPop.patrOrVndr(relcopNo, sellMnatCd, '_new');
					} else if(clmSheet.ColSaveName(col) == 'vndrNm') {
						//제휴사
						var vndrNo = clmSheet.GetCellValue(row, 'vndrNo');
						orderPop.vndrDetail(vndrNo, '_new');
					}
				}
			}

			function clmSheet_OnRowSearchEnd(row) {
				if(clmSheet.GetCellValue(row, 'cnlPayPrc') != '' || clmSheet.GetCellValue(row, 'cnlPayPrc') != '0') {
					clmSheet.SetCellValue(row, 'cnlPayReason', '수수료 발생 사유');
				}
			}

		</script>
	</form>
	</div>
	<jsp:include page="/WEB-INF/jsp/layout/footer.jsp" />
</div>
<!-- 팝업영역 -->
<jsp:include page="/WEB-INF/jsp/popup/company/popCompany.jsp" />	<!-- 고객사 팝업 (표준) -->
<jsp:include page="/WEB-INF/jsp/popup/vendor/popVendor.jsp" />		<!-- 제휴사 팝업 -->
<jsp:include page="/WEB-INF/jsp/popup/partner/popPartner.jsp" />	<!-- 협력사 팝업 -->
<jsp:include page="/WEB-INF/jsp/popup/order/popClaimCmsnRsn.jsp" />	<!-- 취소수수료발생사유 -->
<!--// 팝업영역 -->
</body>
</html>

