import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

class Recommendations extends StatelessWidget {
  // predictedPrice = forecasted next week's price
  // currentPrice = this week's price
  // previousPrice = last week's price
  final double predictedPrice;
  final double currentPrice;
  final double previousPrice;
  final double averagePrice;
  final String? month;
  final String? week;
  final String? year;

  const Recommendations({
    Key? key,
    this.predictedPrice = 1890,
    this.currentPrice = 1800,
    this.previousPrice = 1750,
    this.averagePrice = 1850,
    this.month,
    this.week,
    this.year,
  }) : super(key: key);

  String getRecommendation() {
    // If predicted (next week) price is higher than current price → WAIT (sell next week)
    // If predicted price is lower or equal → SELL now
    return predictedPrice > currentPrice ? 'WAIT' : 'SELL';
  }

  String getRecommendationReason() {
    if (predictedPrice > currentPrice) {
      final priceIncrease = predictedPrice - currentPrice;
      return 'Next week price is Rs. ${priceIncrease.toInt()} higher than current. Wait to sell next week at Rs. ${predictedPrice.toInt()}/kg.';
    } else {
      final priceDrop = currentPrice - predictedPrice;
      return 'Predicted price is Rs. ${priceDrop.toInt()} lower. Sell this week to avoid a drop.';
    }
  }

  String getWaitUntilPrice() {
    // For WAIT recommendations, suggest selling at the predicted (next week) price
    return 'Rs. ${predictedPrice.toInt()}/kg (next week forecast)';
  }

  List<String> getKeyFactors() {
    final priceChange = ((predictedPrice - currentPrice) / currentPrice) * 100;
    final List<String> factors = [];

    factors.add('Previous Week: Rs. ${previousPrice.toInt()}/kg');
    factors.add('Current Week: Rs. ${currentPrice.toInt()}/kg');
    factors.add('Next Week (Predicted): Rs. ${predictedPrice.toInt()}/kg');
    factors.add(
      'Price Change (current → predicted): ${priceChange > 0 ? '+' : ''}${priceChange.toStringAsFixed(1)}%',
    );
    factors.add('Average Price: Rs. ${averagePrice.toInt()}/kg');

    if (predictedPrice > currentPrice) {
      final increase = predictedPrice - currentPrice;
      factors.add(
        'Expected increase: Rs. ${increase.toInt()} per kg next week',
      );
    } else {
      final decrease = currentPrice - predictedPrice;
      factors.add(
        'Expected decrease: Rs. ${decrease.toInt()} per kg next week',
      );
    }

    return factors;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final recommendation = getRecommendation();
    final isSellingRecommendation = recommendation == 'SELL';
    final priceChange = ((predictedPrice - currentPrice) / currentPrice) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "Market Recommendations",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: responsive.largeSpacing),

              // Main Recommendation Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(responsive.largeSpacing),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSellingRecommendation
                        ? [Colors.lightBlue[200]!, Colors.lightBlue[200]!]
                        : [Colors.indigo[400]!, Colors.indigo[400]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isSellingRecommendation
                          ? Colors.lightBlue.withOpacity(0.3)
                          : Colors.indigo.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Recommended Action',
                      style: TextStyle(
                        fontSize: responsive.smallFontSize,
                        color: const Color.fromARGB(179, 0, 0, 0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: responsive.smallSpacing),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.largeSpacing,
                        vertical: responsive.smallSpacing,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recommendation,
                        style: const TextStyle(
                          fontSize: 48,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: responsive.mediumSpacing),
                    Text(
                      getRecommendationReason(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: responsive.bodyFontSize,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.largeSpacing),

              // Period Information and Price Change
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(responsive.mediumSpacing),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.green[700],
                              size: 28,
                            ),
                            SizedBox(height: responsive.smallSpacing / 2),
                            Text(
                              'Period',
                              style: TextStyle(
                                fontSize: responsive.smallFontSize,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${month ?? 'Month'} - ${week ?? 'Week'}',
                              style: TextStyle(
                                fontSize: responsive.bodyFontSize,
                                color: Colors.grey[900],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.blue[700],
                              size: 28,
                            ),
                            SizedBox(height: responsive.smallSpacing / 2),
                            Text(
                              'Price Change',
                              style: TextStyle(
                                fontSize: responsive.smallFontSize,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${priceChange > 0 ? '+' : ''}${priceChange.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: responsive.bodyFontSize,
                                color: priceChange > 0
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (!isSellingRecommendation) ...[
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(responsive.mediumSpacing),
                        decoration: BoxDecoration(
                          color: Colors.indigo[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.indigo[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Colors.indigo[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sell When Price Reaches',
                                  style: TextStyle(
                                    fontSize: responsive.bodyFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              getWaitUntilPrice(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Monitor the market regularly for better selling opportunities.',
                              style: TextStyle(
                                fontSize: responsive.smallFontSize,
                                color: Colors.indigo[800],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
